import * as hre from "hardhat";
import * as contracts from "../contracts.json";
import { Config } from "./config";

const config = Config.BNBTestnet;

async function main() {
    try {
        await hre.run("verify:verify", {
            address: "0x37f33A8AeA00B609c2C07254Ed5BB862d5740e6D",
            constructorArguments: [
                config.router,
                config.usdc,
                config.wormholeRelayer,
                config.tokenBridge,
                config.wormHole,
            ],
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
