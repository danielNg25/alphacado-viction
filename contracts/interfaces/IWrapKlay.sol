// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IWrapKlay {
    function withdraw(uint wad) external;

    function deposit() external payable;
}
