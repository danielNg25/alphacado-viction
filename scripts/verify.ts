import * as hre from "hardhat";
import * as contracts from "../mumbai-contracts.json";
import { Config } from "./config";

const config = Config.Mumbai;

async function main() {
    try {
        await hre.run("verify:verify", {
            address: contracts.mockKlayBankPool,
            constructorArguments: [],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.mockKlayStationPool,
            constructorArguments: [],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.vaultFactory,
            constructorArguments: [],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.tokenFactory,
            constructorArguments: [],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.alphacado,
            constructorArguments: [
                contracts.registry,
                config.usdc,
                config.chainId,
                config.wormholeRelayer,
                config.tokenBridge,
                config.wormHole,
            ],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.registry,
            constructorArguments: [],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.univ2Adapter,
            constructorArguments: [contracts.alphacado],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.klayBankAdapter,
            constructorArguments: [contracts.alphacado],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.klayStationAdapter,
            constructorArguments: [contracts.alphacado],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }

    try {
        await hre.run("verify:verify", {
            address: contracts.vaultAdapter,
            constructorArguments: [contracts.alphacado],
            hre,
        });
    } catch (err) {
        console.log("err >>", err);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
