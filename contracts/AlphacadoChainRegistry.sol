// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./interfaces/IAlphacadoChainRegistry.sol";

error ChainIdNotSupported(uint256 chainId);
error AdapterNotFound(uint16 actionId);

contract AlphacadoChainRegistry is IAlphacadoChainRegistry, Ownable2Step {
    // mapping from chain id to alphacado address
    mapping(uint16 => address) private registry;
    // mapping from action id to adapter address
    mapping(uint16 => address) private adapters;
    // mapping from chain id to action id to bool
    mapping(uint16 => mapping(uint16 => bool)) public targetchainActionId;

    event AlphacadoAddressSet(
        uint256 indexed chainId,
        address indexed alphacadoAddress
    );

    constructor() {}

    function isSupported(uint16 chainId) external view returns (bool) {
        return registry[chainId] != address(0);
    }

    function getAdapter(uint16 actionId) external view returns (address) {
        address adapter = adapters[actionId];

        if (adapter == address(0)) {
            revert AdapterNotFound(actionId);
        }

        return adapter;
    }

    function getAlphacadoAddress(
        uint16 chainId
    ) external view returns (address) {
        address alphacadoAddress = registry[chainId];
        if (alphacadoAddress == address(0)) {
            revert ChainIdNotSupported(chainId);
        }
        return alphacadoAddress;
    }

    function setAlphacadoAddress(
        uint16 chainId,
        address alphacadoAddress
    ) external onlyOwner {
        registry[chainId] = alphacadoAddress;
        emit AlphacadoAddressSet(chainId, alphacadoAddress);
    }

    function setAdapter(uint16 actionId, address adapter) external onlyOwner {
        adapters[actionId] = adapter;
    }

    function setTargetChainActionId(
        uint16 targetChainId,
        uint16 actionId,
        bool value
    ) external onlyOwner {
        targetchainActionId[targetChainId][actionId] = value;
    }
}
