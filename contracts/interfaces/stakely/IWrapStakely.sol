// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWrapStakely is IERC20 {
    function stKlay() external view returns (address);

    function wrap(uint256 amount) external;

    function unwrap(uint256 amount) external;

    function getWrappedAmount(
        uint256 amount
    ) external view returns (uint256 wrappedAmount);

    function getUnwrappedAmount(
        uint256 amount
    ) external view returns (uint256 unwrappedAmount);
}
