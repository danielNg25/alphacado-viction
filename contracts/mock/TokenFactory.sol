// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ExchangeableSourceChainERC20.sol";
import "./ExchangeableTargetChainERC20.sol";

contract TokenFactory {
    function createSourceChainToken(
        string memory name,
        string memory symbol,
        address exchangeToken,
        uint8 rate
    ) external returns (address) {
        return
            address(
                new ExchangeableSourceChainERC20(
                    name,
                    symbol,
                    exchangeToken,
                    rate
                )
            );
    }

    function createTargetChainToken(
        string memory name,
        string memory symbol,
        address exchangeToken,
        uint8 rate
    ) external returns (address) {
        return
            address(
                new ExchangeableTargetChainERC20(
                    name,
                    symbol,
                    exchangeToken,
                    rate
                )
            );
    }
}
