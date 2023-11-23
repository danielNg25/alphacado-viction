// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../adapters/klaystation/IKlayStationPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockKlayStationPool is IKlayStationPool, ERC20 {
    constructor() ERC20("KlayBank", "KLB") {}

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        _mint(onBehalfOf, amount);
    }
}
