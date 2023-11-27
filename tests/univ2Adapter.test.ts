import * as hre from "hardhat";
import { expect } from "chai";
import { ethers } from "hardhat";

import {
    AlphacadoMock__factory,
    AlphacadoMock,
    UniswapAdapterV2TokenAdapterMock__factory,
    UniswapAdapterV2TokenAdapterMock,
    ERC20Mock__factory,
    ERC20Mock,
    AlphacadoChainRegistry__factory,
    AlphacadoChainRegistry,
    TokenFactory__factory,
    TokenFactory,
    ExchangeableSourceChainERC20,
    ExchangeableSourceChainERC20__factory,
    ExchangeableTargetChainERC20,
    ExchangeableTargetChainERC20__factory,
} from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("UniV2Adapter", () => {
    let user: SignerWithAddress;
    let mockUSDC: ERC20Mock;
    let alphacado: AlphacadoMock;
    let univ2Adapter: UniswapAdapterV2TokenAdapterMock;
    let registry: AlphacadoChainRegistry;
    let tokenFactory: TokenFactory;

    let sourceChainToken: ExchangeableSourceChainERC20;
    let targetChainToken: ExchangeableTargetChainERC20;

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

        const Alphacado: AlphacadoMock__factory =
            await ethers.getContractFactory("AlphacadoMock");
        alphacado = await Alphacado.deploy(
            await registry.getAddress(),
            await mockUSDC.getAddress(),
            1, // chainId
            user.address, // wormhole relayer
            ethers.ZeroAddress, // token bridge
            ethers.ZeroAddress, // wormhole
        );

        const UniV2Adapter: UniswapAdapterV2TokenAdapterMock__factory =
            await ethers.getContractFactory("UniswapAdapterV2TokenAdapterMock");

        univ2Adapter = await UniV2Adapter.deploy(await alphacado.getAddress());

        await registry.setAdapter(1, await univ2Adapter.getAddress());
        await registry.setAlphacadoAddress(1, await alphacado.getAddress());
        await registry.setTargetChainActionId(1, 1, true);

        const TokenFactory: TokenFactory__factory =
            await ethers.getContractFactory("TokenFactory");

        tokenFactory = await TokenFactory.deploy();

        await tokenFactory.createSourceChainToken(
            "Ethereum",
            "ETH",
            await mockUSDC.getAddress(),
            50000,
        );

        await tokenFactory.createTargetChainToken(
            "Ethereum",
            "ETH",
            await mockUSDC.getAddress(),
            50000,
        );

        const SourceChainToken: ExchangeableSourceChainERC20__factory =
            await ethers.getContractFactory("ExchangeableSourceChainERC20");

        sourceChainToken = <ExchangeableSourceChainERC20>(
            SourceChainToken.attach(await tokenFactory.tokens(0))
        );

        const TargetChainToken: ExchangeableTargetChainERC20__factory =
            await ethers.getContractFactory("ExchangeableTargetChainERC20");

        targetChainToken = <ExchangeableTargetChainERC20>(
            TargetChainToken.attach(await tokenFactory.tokens(1))
        );

        hre.tracer.nameTags[await alphacado.getAddress()] = "Alphacado";
    });

    describe("Should create request successful", () => {
        it("Should create request successful", async () => {
            await sourceChainToken.mint(user.address, ethers.parseEther("1"));
            await sourceChainToken.approve(
                await univ2Adapter.getAddress(),
                ethers.parseEther("1"),
            );

            const payload = ethers.AbiCoder.defaultAbiCoder().encode(
                ["address", "address", "uint256", "bytes"],
                [
                    ethers.ZeroAddress, // target chain univ2 router
                    ethers.ZeroAddress, // target chain tokenB
                    ethers.parseEther("1"), // minimum liquidity receive target chain
                    "0x",
                ],
            );

            await expect(
                univ2Adapter.fromUniV2Token(
                    ethers.ZeroAddress,
                    await sourceChainToken.getAddress(),
                    ethers.parseEther("1"),
                    ethers.parseEther("2000"),
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
                ["address", "address", "uint256", "bytes"],
                [
                    ethers.ZeroAddress, // target chain univ2 router
                    await targetChainToken.getAddress(), // target chain tokenB
                    ethers.parseEther("1"), // minimum liquidity receive target chain
                    "0x",
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
                ethers.parseEther("2000"),
            );

            await alphacado
                .connect(user)
                .receivePayloadAndTokensMock(
                    payload,
                    ethers.parseEther("2000"),
                );
        });
    });
});
