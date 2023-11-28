// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStakely is IERC20 {
    function stake() external payable;

    function unstake(uint256 amount) external;

    function getSharesByKlay(uint256 amount) external view returns (uint256);

    function getKlayByShares(uint256 amount) external view returns (uint256);
}
