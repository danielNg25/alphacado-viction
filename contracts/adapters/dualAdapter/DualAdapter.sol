// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../AdapterBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DualAdapter is AdapterBase {
    uint16 public constant BASIS_POINTS = 10000;

    constructor(address _alphacado) AdapterBase(_alphacado) {}

    function executeReceived(
        uint16 sourceChainId,
        uint256 sourceChainRequestId,
        address token,
        uint256 amount,
        address receipient,
        bytes memory payload
    ) external override {
        (
            bytes memory firstActionIdPayload,
            bytes memory secondActionIdPayload
        ) = abi.decode(payload, (bytes, bytes));

        IAlphacadoChainRegistry chainRegistry = IAlphacadoChainRegistry(
            alphacado.registry()
        );

        (
            uint16 firstActionId,
            uint16 firstActionPercent,
            bytes memory firstActionPayload
        ) = abi.decode(firstActionIdPayload, (uint16, uint16, bytes));

        (
            uint16 secondActionId,
            uint16 secondActionPercent,
            bytes memory secondActionPayload
        ) = abi.decode(secondActionIdPayload, (uint16, uint16, bytes));

        require(
            firstActionPercent + secondActionPercent == BASIS_POINTS,
            "DualAdapter: Invalid percent"
        );

        uint256 firstActionAmount = (amount * firstActionPercent) /
            BASIS_POINTS;

        uint256 secondActionAmount = (amount - firstActionAmount);

        _executeAction(
            sourceChainId,
            sourceChainRequestId,
            chainRegistry,
            firstActionId,
            token,
            firstActionAmount,
            receipient,
            firstActionPayload
        );

        _executeAction(
            sourceChainId,
            sourceChainRequestId,
            chainRegistry,
            secondActionId,
            token,
            secondActionAmount,
            receipient,
            secondActionPayload
        );
    }
}
