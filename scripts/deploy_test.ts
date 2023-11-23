import * as hre from "hardhat";
import * as fs from "fs";
import { Signer } from "ethers";
const ethers = hre.ethers;
import { Config } from "./config";

import {
    Alphacado__factory,
    Alphacado,
    MockUniswapV2Adapter__factory,
    AlphacadoChainRegistry__factory,
} from "../typechain-types";

const config = Config.Mumbai;

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

    const MockUniswapV2Adapter: MockUniswapV2Adapter__factory =
        await ethers.getContractFactory("MockUniswapV2Adapter");

    // Deploy contracts
    console.log(
        "==================================================================",
    );
    console.log("DEPLOY CONTRACTS");
    console.log(
        "==================================================================",
    );

    console.log("ACCOUNT: " + admin);
    const registry = await AlphacadoChainRegistry.deploy();

    await registry.waitForDeployment();

    console.log("Registry deployed at: ", await registry.getAddress());
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

    console.log("Alphacado deployed at: ", alphacadoAddress);
    const univ2Adapter = await MockUniswapV2Adapter.deploy(
        await alphacado.getAddress(),
    );

    await univ2Adapter.waitForDeployment();

    console.log("Univ2Adapter deployed at: ", await univ2Adapter.getAddress());

    await registry.setAdapter(1, await univ2Adapter.getAddress());

    console.log("Adapter set at registry");
    const contractAddress = {
        alphacado: alphacadoAddress,
        registry: await registry.getAddress(),
        univ2Adapter: await univ2Adapter.getAddress(),
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
