import * as hre from "hardhat";
import * as fs from "fs";
import { Signer } from "ethers";
const ethers = hre.ethers;
import { Config } from "./config";

import { ERC20Mock__factory, ERC20Mock } from "../typechain-types";

async function main() {
    //Loading accounts
    const accounts: Signer[] = await ethers.getSigners();
    const admin = await accounts[0].getAddress();
    //Loading contracts' factory

    const config = Config.Mumbai;

    const ERC20Mock: ERC20Mock__factory = await ethers.getContractFactory(
        "ERC20Mock",
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

    const erc20: ERC20Mock = await ERC20Mock.deploy("tUSDC", "tUSDC");
    await erc20.waitForDeployment();

    const erc20Address = await erc20.getAddress();

    console.log("erc20 deployed at: ", erc20Address);

    const contractAddress = {
        erc20: erc20Address,
    };

    fs.writeFileSync("tokenContracts.json", JSON.stringify(contractAddress));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
