import { ethers } from "ethers";

const gen = (
    targetChainUniV2Router: string,
    targetChainTokenB: string,
    minimumLiquidityReceiveTargetChain: bigint,
) => {
    const payload = ethers.AbiCoder.defaultAbiCoder().encode(
        ["address", "address", "uint256"],
        [
            targetChainUniV2Router,
            targetChainTokenB,
            minimumLiquidityReceiveTargetChain,
        ],
    );

    console.log(payload);
};

gen(
    ethers.ZeroAddress, // target chain univ2 router
    ethers.ZeroAddress, // target chain tokenB
    ethers.parseEther("1"), // minimum liquidity receive target chain
);
