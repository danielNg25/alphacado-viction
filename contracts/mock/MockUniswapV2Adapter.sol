// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../adapters/uniswap/zapper/ZapperUniswapV2.sol";
import "../interfaces/IAlphacado.sol";
import "../libraries/UniswapV2Library.sol";
import "../adapters/AdapterBase.sol";
import "./IMintable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract MockUniswapV2Adapter is ZapperUniswapV2, AdapterBase, ERC20 {
    constructor(
        address _alphacado
    ) AdapterBase(_alphacado) ERC20("Liquidity Token", "LP") {}

    function fromUniV2(
        IUniswapV2Router02 router,
        address tokenB,
        uint256 liquidity,
        uint256 minimumSendAmount,
        uint16 targetChain,
        uint16 targetChainActionId,
        address receipient,
        bytes calldata payload
    ) external {
        address USDC = alphacado.USDC();
        // address pair = UniswapV2Library.pairFor(router.factory(), USDC, tokenB);

        // IERC20(address(pair)).transferFrom(
        //     msg.sender,
        //     address(this),
        //     liquidity
        // );

        IMintable(USDC).mint(address(alphacado), minimumSendAmount);

        alphacado.sendCrossChainRequest(
            msg.sender,
            targetChain,
            targetChainActionId,
            receipient,
            minimumSendAmount,
            payload
        );
    }

    function executeReceived(
        address,
        uint256,
        address receipient,
        // payload shouble abi encode of (targetChainRouter, targetChainTokenB, targetChainMinimumReceiveLiquidity)
        bytes memory payload
    ) external override {
        (, , uint256 minimumReceiveLiquidity) = abi.decode(
            payload,
            (address, address, uint256)
        );

        _mint(receipient, minimumReceiveLiquidity);
    }
}
