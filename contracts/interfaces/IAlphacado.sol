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
    ) external;
}
