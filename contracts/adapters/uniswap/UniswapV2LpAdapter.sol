// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./zapper/ZapperUniswapV2.sol";
import "../../interfaces/IAlphacado.sol";
import "../../libraries/UniswapV2Library.sol";
import "../AdapterBase.sol";

contract UniswapAdapterV2LpAdapter is ZapperUniswapV2, AdapterBase {
    constructor(address _alphacado) AdapterBase(_alphacado) {}

    function fromUniV2LP(
        IUniswapV2Router02 router,
        address tokenB,
        uint256 liquidity,
        uint256 minimumSendAmount,
        uint16 targetChain,
        uint16 targetChainActionId,
        address receipient,
        bytes calldata payload
    ) external payable {
        address USDC = alphacado.USDC();
        address pair = UniswapV2Library.pairFor(router.factory(), USDC, tokenB);

        uint amountUSDC = zapOut(
            router,
            IUniswapV2Pair(pair),
            liquidity,
            USDC,
            minimumSendAmount,
            ""
        );

        IERC20(USDC).transfer(address(alphacado), amountUSDC);

        alphacado.sendCrossChainRequest{value: msg.value}(
            msg.sender,
            targetChain,
            targetChainActionId,
            receipient,
            amountUSDC,
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
            address router,
            address tokenB,
            uint256 minimumReceiveLiquidity,
            bytes memory additionActionIdPayload
        ) = abi.decode(payload, (address, address, uint256, bytes));

        address pair = UniswapV2Library.pairFor(
            IUniswapV2Router02(router).factory(),
            token,
            tokenB
        );

        if (additionActionIdPayload.length > 0) {
            uint256 receivedLiquidity = zapIn(
                IUniswapV2Router02(router),
                IUniswapV2Pair(pair),
                token,
                address(alphacado),
                amount,
                minimumReceiveLiquidity,
                ""
            );

            (uint16 actionId, bytes memory additionActionPayload) = abi.decode(
                additionActionIdPayload,
                (uint16, bytes)
            );

            alphacado.executeReceived(
                sourceChainId,
                sourceChainRequestId,
                pair,
                receivedLiquidity,
                actionId,
                receipient,
                additionActionPayload
            );
        } else {
            zapIn(
                IUniswapV2Router02(router),
                IUniswapV2Pair(pair),
                token,
                receipient,
                amount,
                minimumReceiveLiquidity,
                ""
            );
        }
    }
}
