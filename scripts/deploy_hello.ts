import * as hre from "hardhat";
import * as fs from "fs";
import { Signer } from "ethers";
const ethers = hre.ethers;
import { Config } from "./config";

import { HelloToken__factory, HelloToken } from "../typechain-types";

async function main() {
    //Loading accounts
    const accounts: Signer[] = await ethers.getSigners();
    const admin = await accounts[0].getAddress();
    //Loading contracts' factory

    const config = Config.BNBTestnet;

    const HelloToken: HelloToken__factory = await ethers.getContractFactory(
        "HelloToken",
    );

    // Deploy contracts
    console.log(
        "==================================================================",
    );
    console.log("DEPLOY CONTRACTS");
    console.log(
        "==================================================================",
    );

    console.log("ACCOUNT: " + admin);

    const hello: HelloToken = await HelloToken.deploy(
        config.wormholeRelayer,
        config.tokenBridge,
        config.wormHole,
    );
    await hello.waitForDeployment();

    const greaterAddress = await hello.getAddress();

    console.log("hello deployed at: ", greaterAddress);

    const contractAddress = {
        hello: greaterAddress,
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
