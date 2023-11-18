import * as hre from "hardhat";
import * as fs from "fs";
import { Signer } from "ethers";
const ethers = hre.ethers;
import { Config } from "./config";

import { Alphacado__factory, Alphacado } from "../typechain-types";

const config = Config.BNBTestnet;

async function main() {
    //Loading accounts
    const accounts: Signer[] = await ethers.getSigners();
    const admin = await accounts[0].getAddress();
    //Loading contracts' factory

    const Alphacado: Alphacado__factory = await ethers.getContractFactory(
        "Alphacado",
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

    const alphacado: Alphacado = await Alphacado.deploy(
        config.router,
        config.usdc,
        config.wormholeRelayer,
        config.tokenBridge,
        config.wormHole,
    );
    await alphacado.waitForDeployment();

    const alphacadoAddress = await alphacado.getAddress();

    console.log("sender deployed at: ", alphacadoAddress);

    const contractAddress = {
        sender: alphacadoAddress,
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
