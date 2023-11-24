// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../AdapterBase.sol";
import "../../vault/IVault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VaultAdapter is AdapterBase {
    constructor(address _alphacado) AdapterBase(_alphacado) {}

    function executeReceived(
        uint16 sourceChainId,
        uint256 sourceChainRequestId,
        address token,
        uint256 amount,
        address receipient,
        bytes memory payload
    ) external override {
        address vault = abi.decode(payload, (address));

        IERC20(token).approve(vault, amount);
        IVault(vault).deposit(amount, receipient);
    }
}
