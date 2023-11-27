// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../interfaces/IAlphacado.sol";
import "../libraries/UniswapV2Library.sol";
import "../adapters/AdapterBase.sol";
import "./ExchangeableSourceChainERC20.sol";
import "./ExchangeableTargetChainERC20.sol";

contract UniswapAdapterV2TokenAdapterMock is AdapterBase {
    constructor(address _alphacado) AdapterBase(_alphacado) {}

    function fromUniV2Token(
        IUniswapV2Router02,
        address token,
        uint256 amount,
        uint256 minimumSendAmount,
        uint16 targetChain,
        uint16 targetChainActionId,
        address receipient,
        bytes calldata payload
    ) external payable {
        address USDC = alphacado.USDC();

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = USDC;

        ExchangeableSourceChainERC20(token).transferFrom(
            msg.sender,
            token,
            amount
        );

        uint256 receivedAmount = ExchangeableSourceChainERC20(token)
            .burnAndMint(address(alphacado), amount);
        require(
            receivedAmount >= minimumSendAmount,
            "UniswapAdapterV2TokenAdapterMock: receivedAmount < minimumSendAmount"
        );

        alphacado.sendCrossChainRequest{value: msg.value}(
            msg.sender,
            targetChain,
            targetChainActionId,
            receipient,
            receivedAmount,
            payload
        );
    }

    function fromUniV2LP(
        IUniswapV2Router02,
        address token,
        uint256 liquidity,
        uint256 minimumSendAmount,
        uint16 targetChain,
        uint16 targetChainActionId,
        address receipient,
        bytes calldata payload
    ) external payable {
        address USDC = alphacado.USDC();

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = USDC;

        ExchangeableSourceChainERC20(token).transferFrom(
            msg.sender,
            token,
            liquidity
        );

        uint256 receivedAmount = ExchangeableSourceChainERC20(token)
            .burnAndMint(address(alphacado), liquidity);

        require(
            receivedAmount >= minimumSendAmount,
            "UniswapAdapterV2TokenAdapterMock: receivedAmount < minimumSendAmount"
        );

        alphacado.sendCrossChainRequest{value: msg.value}(
            msg.sender,
            targetChain,
            targetChainActionId,
            receipient,
            receivedAmount,
            payload
        );
    }

    function executeReceived(
        uint16 sourceChainId,
        uint256 sourceChainRequestId,
        address token,
        uint256 amount,
        address receipient,
        // payload shouble abi encode of (targetChainRouter, targetChainTokenB, targetChainMinimumReceiveLiquidity)
        bytes memory payload
    ) external override {
        (
            ,
            address tokenB,
            uint256 minimumReceive,
            bytes memory additionActionIdPayload
        ) = abi.decode(payload, (address, address, uint256, bytes));

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenB;

        IERC20(token).transfer(tokenB, amount);

        if (additionActionIdPayload.length > 0) {
            uint256 receivedAmount = ExchangeableTargetChainERC20(tokenB).mint(
                address(alphacado),
                amount
            );

            require(
                receivedAmount >= minimumReceive,
                "UniswapAdapterV2TokenAdapterMock: receivedAmount < minimumReceive"
            );

            (uint16 actionId, bytes memory additionActionPayload) = abi.decode(
                additionActionIdPayload,
                (uint16, bytes)
            );

            alphacado.executeReceived(
                sourceChainId,
                sourceChainRequestId,
                tokenB,
                receivedAmount,
                actionId,
                receipient,
                additionActionPayload
            );
        } else {
            uint256 receivedAmount = ExchangeableTargetChainERC20(tokenB).mint(
                receipient,
                amount
            );
            require(
                receivedAmount >= minimumReceive,
                "UniswapAdapterV2TokenAdapterMock: receivedAmount < minimumReceive"
            );
        }
    }
}
