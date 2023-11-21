import * as hre from "hardhat";
import { expect } from "chai";
import { ethers } from "hardhat";

import {
    MockAlphacado__factory,
    MockAlphacado,
    MockUniswapV2Adapter__factory,
    MockUniswapV2Adapter,
    ERC20Mock__factory,
    ERC20Mock,
    AlphacadoChainRegistry__factory,
    AlphacadoChainRegistry,
} from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

import { time } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("UniV2Adapter", () => {
    let user: SignerWithAddress;
    let mockUSDC: ERC20Mock;
    let alphacado: MockAlphacado;
    let univ2Adapter: MockUniswapV2Adapter;
    let registry: AlphacadoChainRegistry;

    beforeEach(async () => {
        const accounts: SignerWithAddress[] = await ethers.getSigners();
        user = accounts[0];

        const ERC20Mock: ERC20Mock__factory = await ethers.getContractFactory(
            "ERC20Mock",
        );

        mockUSDC = await ERC20Mock.deploy("USDC", "USDC");

        const AlphacadoChainRegistry: AlphacadoChainRegistry__factory =
            await ethers.getContractFactory("AlphacadoChainRegistry");

        registry = await AlphacadoChainRegistry.deploy();

        const Alphacado: MockAlphacado__factory =
            await ethers.getContractFactory("MockAlphacado");
        alphacado = await Alphacado.deploy(
            await registry.getAddress(),
            await mockUSDC.getAddress(),
            1, // chainId
            user.address, // wormhole relayer
            ethers.ZeroAddress, // token bridge
            ethers.ZeroAddress, // wormhole
        );

        const UniV2Adapter: MockUniswapV2Adapter__factory =
            await ethers.getContractFactory("MockUniswapV2Adapter");

        univ2Adapter = await UniV2Adapter.deploy(await alphacado.getAddress());

        await registry.setAdapter(1, await univ2Adapter.getAddress());
        await registry.setAlphacadoAddress(1, await alphacado.getAddress());
        await registry.setTargetChainActionId(1, 1, true);

        hre.tracer.nameTags[await alphacado.getAddress()] = "Alphacado";
    });

    describe("Should create request successful", () => {
        it("Should create request successful", async () => {
            const payload = ethers.AbiCoder.defaultAbiCoder().encode(
                ["address", "address", "uint256"],
                [
                    ethers.ZeroAddress, // target chain univ2 router
                    ethers.ZeroAddress, // target chain tokenB
                    ethers.parseEther("1"), // minimum liquidity receive target chain
                ],
            );

            await expect(
                univ2Adapter.fromUniV2(
                    ethers.ZeroAddress,
                    ethers.ZeroAddress,
                    ethers.parseEther("1"),
                    ethers.parseEther("1"),
                    1,
                    1,
                    user.address,
                    payload,
                ),
            ).to.revertedWithCustomError(alphacado, "CallSuccess");
        });
    });

    describe("Should receive request successful", () => {
        it("Should receive request successful", async () => {
            const actionPayload = ethers.AbiCoder.defaultAbiCoder().encode(
                ["address", "address", "uint256"],
                [
                    ethers.ZeroAddress, // target chain univ2 router
                    ethers.ZeroAddress, // target chain tokenB
                    ethers.parseEther("1"), // minimum liquidity receive target chain
                ],
            );

            const payload = ethers.AbiCoder.defaultAbiCoder().encode(
                ["uint16", "uint256", "uint16", "address", "bytes"],
                [
                    1, // source chain id,
                    1, // source chain request id
                    1, // action id
                    user.address, // user address
                    actionPayload,
                ],
            );

            await mockUSDC.mint(
                await alphacado.getAddress(),
                ethers.parseEther("1"),
            );

            await alphacado
                .connect(user)
                .receivePayloadAndTokensMock(payload, ethers.parseEther("1"));
        });
    });
});
