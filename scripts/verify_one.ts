import * as hre from "hardhat";

async function main() {
    try {
        await hre.run("verify:verify", {
            address: "0x5707F6d31a55d10dA5585B78AA7D95F9A41eBe7D",
            constructorArguments: [
                "Klaytn",
                "KLAY",
                "0x87A35f50E570F909F275F5C8AEC40FbeB9e76D17",
                "20000000",
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
