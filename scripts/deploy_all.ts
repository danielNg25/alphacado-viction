import * as hre from "hardhat";
import * as fs from "fs";
import { Signer } from "ethers";
const ethers = hre.ethers;
import { Config } from "./config";

import {
    Alphacado__factory,
    Alphacado,
    UniswapAdapterV2LpAdapter__factory,
    MockKlayBankPool__factory,
    KlayBankAdapter__factory,
    MockKlayStationPool__factory,
    KlayStationAdapter__factory,
    VaultFactory__factory,
    VaultAdapter__factory,
    AlphacadoChainRegistry__factory,
} from "../typechain-types";

const config = Config.BNBTestnet;

async function main() {
    //Loading accounts
    const accounts: Signer[] = await ethers.getSigners();
    const admin = await accounts[0].getAddress();
    //Loading contracts' factory

    const Alphacado: Alphacado__factory = await ethers.getContractFactory(
        "Alphacado",
    );

    const AlphacadoChainRegistry: AlphacadoChainRegistry__factory =
        await ethers.getContractFactory("AlphacadoChainRegistry");

    const MockKlayBankPool: MockKlayBankPool__factory =
        await ethers.getContractFactory("MockKlayBankPool");

    const KlayBankAdapter: KlayBankAdapter__factory =
        await ethers.getContractFactory("KlayBankAdapter");

    const MockKlayStationPool: MockKlayStationPool__factory =
        await ethers.getContractFactory("MockKlayStationPool");

    const KlayStationAdapter: KlayStationAdapter__factory =
        await ethers.getContractFactory("KlayStationAdapter");

    const VaultFactory: VaultFactory__factory = await ethers.getContractFactory(
        "VaultFactory",
    );

    const VaultAdapter: VaultAdapter__factory = await ethers.getContractFactory(
        "VaultAdapter",
    );

    const UniswapAdapter: UniswapAdapterV2LpAdapter__factory =
        await ethers.getContractFactory("UniswapAdapterV2LpAdapter");

    // Deploy contracts
    console.log(
        "==================================================================",
    );
    console.log("DEPLOY CONTRACTS");
    console.log(
        "==================================================================",
    );
    console.log("ACCOUNT: " + admin);
    console.log("Deploying Mock contract");
    const mockKlayBankPool = await MockKlayBankPool.deploy();
    await mockKlayBankPool.waitForDeployment();

    const mockKlayStationPool = await MockKlayStationPool.deploy();
    await mockKlayStationPool.waitForDeployment();

    const vaultFactory = await VaultFactory.deploy();
    await vaultFactory.waitForDeployment();

    console.log("Deploying Alphacado contract");

    const registry = await AlphacadoChainRegistry.deploy();

    await registry.waitForDeployment();
    const alphacado: Alphacado = await Alphacado.deploy(
        await registry.getAddress(),
        config.usdc,
        config.chainId,
        config.wormholeRelayer,
        config.tokenBridge,
        config.wormHole,
    );

    await alphacado.waitForDeployment();

    const alphacadoAddress = await alphacado.getAddress();

    console.log("alphacado deployed at: ", alphacadoAddress);

    console.log("Deploying Adapter contract");

    console.log("Deploying Univ2 Adapter contract");
    const univ2Adapter = await UniswapAdapter.deploy(alphacadoAddress);
    await univ2Adapter.waitForDeployment();

    await registry.setAdapter(1, await univ2Adapter.getAddress());

    console.log("Deploying KlayBank Adapter contract");
    const klayBankAdapter = await KlayBankAdapter.deploy(alphacadoAddress);
    await klayBankAdapter.waitForDeployment();

    await registry.setAdapter(2, await klayBankAdapter.getAddress());

    console.log("Deploying KlayStation Adapter contract");
    const klayStationAdapter = await KlayStationAdapter.deploy(
        alphacadoAddress,
    );
    await klayStationAdapter.waitForDeployment();

    await registry.setAdapter(3, await klayStationAdapter.getAddress());

    console.log("Deploying Vault Adapter contract");
    const vaultAdapter = await VaultAdapter.deploy(alphacadoAddress);
    await vaultAdapter.waitForDeployment();

    await registry.setAdapter(4, await vaultAdapter.getAddress());

    const contractAddress = {
        mockKlayBankPool: await mockKlayBankPool.getAddress(),
        mockKlayStationPool: await mockKlayStationPool.getAddress(),
        vaultFactory: await vaultFactory.getAddress(),
        alphacado: alphacadoAddress,
        registry: await registry.getAddress(),
        univ2Adapter: await univ2Adapter.getAddress(),
        klayBankAdapter: await klayBankAdapter.getAddress(),
        klayStationAdapter: await klayStationAdapter.getAddress(),
        vaultAdapter: await vaultAdapter.getAddress(),
    };

    fs.writeFileSync("contracts.json", JSON.stringify(contractAddress));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
