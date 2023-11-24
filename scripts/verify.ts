import * as hre from "hardhat";
// import * as contracts from "../mumbai-contracts.json";
// import { Config } from "./config";

// const config = Config.Mumbai;

async function main() {
    try {
        await hre.run("verify:verify", {
            address: "0x9E39a440A5420892b5183b2E3F4FBF01eE6FE9EC",
            constructorArguments: [],
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
