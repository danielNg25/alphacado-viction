// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../AdapterBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IKlayBankLendingPool.sol";

contract KlayBankAdapter is AdapterBase {
    constructor(address _alphacado) AdapterBase(_alphacado) {}

    function executeReceived(
        uint16,
        uint256,
        address token,
        uint256 amount,
        address receipient,
        bytes memory payload
    ) external override {
        (address pool, uint16 referralCode) = abi.decode(
            payload,
            (address, uint16)
        );

        IERC20(token).approve(pool, amount);
        IKlayBankLendingPool(pool).deposit(
            token,
            amount,
            receipient,
            referralCode
        );
    }
}
