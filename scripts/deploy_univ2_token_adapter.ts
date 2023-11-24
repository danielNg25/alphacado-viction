import * as hre from "hardhat";
import * as fs from "fs";
import { Signer } from "ethers";
const ethers = hre.ethers;
import { Config } from "./config";

import {
    UniswapAdapterV2TokenAdapter__factory,
    AlphacadoChainRegistry__factory,
    AlphacadoChainRegistry,
} from "../typechain-types";
import BNBContract from "../bnbtestnet-contracts.json";
import MumbaiContract from "../mumbai-contracts.json";

const Addresses = MumbaiContract;

async function main() {
    //Loading accounts
    const accounts: Signer[] = await ethers.getSigners();
    const admin = await accounts[0].getAddress();
    //Loading contracts' factory

    const AlphacadoChainRegistry: AlphacadoChainRegistry__factory =
        await ethers.getContractFactory("AlphacadoChainRegistry");

    const UniswapAdapter: UniswapAdapterV2TokenAdapter__factory =
        await ethers.getContractFactory("UniswapAdapterV2TokenAdapter");

    // Deploy contracts
    console.log(
        "==================================================================",
    );
    console.log("DEPLOY CONTRACTS");
    console.log(
        "==================================================================",
    );
    console.log("ACCOUNT: " + admin);

    const registry = <AlphacadoChainRegistry>(
        AlphacadoChainRegistry.attach(Addresses.registry)
    );

    console.log("Deploying Adapter contract");

    console.log("Deploying Univ2 Adapter contract");
    const univ2Adapter = await UniswapAdapter.deploy(Addresses.alphacado);
    await univ2Adapter.waitForDeployment();

    await registry.setAdapter(1, await univ2Adapter.getAddress());

    const contractAddress = {
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
