// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../../interfaces/IAlphacado.sol";
import "../../libraries/UniswapV2Library.sol";
import "../AdapterBase.sol";

contract UniswapV2TokenAdapter is AdapterBase {
    constructor(address _alphacado) AdapterBase(_alphacado) {}

    function fromUniV2Token(
        IUniswapV2Router02 router,
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

        uint256[] memory receivedAmounts = router.swapExactTokensForTokens(
            amount,
            minimumSendAmount,
            path,
            address(alphacado),
            block.timestamp + 1
        );

        alphacado.sendCrossChainRequest{value: msg.value}(
            msg.sender,
            targetChain,
            targetChainActionId,
            receipient,
            receivedAmounts[0],
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
            uint256 minimumReceive,
            bytes memory additionActionIdPayload
        ) = abi.decode(payload, (address, address, uint256, bytes));

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenB;

        if (additionActionIdPayload.length > 0) {
            uint256[] memory amounts = IUniswapV2Router02(router)
                .swapExactTokensForTokens(
                    amount,
                    minimumReceive,
                    path,
                    address(alphacado),
                    block.timestamp + 1
                );

            (uint16 actionId, bytes memory additionActionPayload) = abi.decode(
                additionActionIdPayload,
                (uint16, bytes)
            );

            IAlphacadoChainRegistry chainRegistry = IAlphacadoChainRegistry(
                alphacado.registry()
            );

            _executeAction(
                sourceChainId,
                sourceChainRequestId,
                chainRegistry,
                actionId,
                tokenB,
                amounts[0],
                receipient,
                additionActionPayload
            );
        } else {
            IUniswapV2Router02(router).swapExactTokensForTokens(
                amount,
                minimumReceive,
                path,
                receipient,
                block.timestamp + 1
            );
        }
    }
}
