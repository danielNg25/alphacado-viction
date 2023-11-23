// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IVault {
    function deposit(uint256 _amount, address onBehalfOf) external;
}
