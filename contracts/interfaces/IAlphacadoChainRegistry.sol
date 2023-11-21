// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAlphacadoChainRegistry {
    function getAdapter(uint16) external view returns (address);

    function targetchainActionId(uint16, uint16) external view returns (bool);

    function isSupported(uint16 chainId) external view returns (bool);

    function getAlphacadoAddress(
        uint16 chainId
    ) external view returns (address);

    function setAlphacadoAddress(
        uint16 chainId,
        address alphacadoAddress
    ) external;
}
