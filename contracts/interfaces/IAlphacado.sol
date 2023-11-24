// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAlphacado {
    function USDC() external view returns (address);

    function sendCrossChainRequest(
        address sender,
        uint16 targetChain,
        uint16 targetChainActionId,
        address receipient,
        uint256 amountUSDC,
        bytes calldata payload
    ) external payable;

    function executeReceived(
        uint16 sourceChainId,
        uint256 sourceChainRequestId,
        address token,
        uint256 amount,
        uint16 actionId,
        address receipient,
        bytes memory payload
    ) external;
}
