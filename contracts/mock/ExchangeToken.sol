// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20Mock} from "./MockERC20.sol";

contract ExchangeableToken {
    ERC20Mock public firstToken;
    ERC20Mock public secondToken;
    uint256 public constant RATE_DECIMALS = 10 ** 8;
    uint256 public rate;

    constructor(address _firstToken, address _secondToken, uint256 _rate) {
        firstToken = ERC20Mock(_firstToken);
        secondToken = ERC20Mock(_secondToken);
        rate = _rate;
    }

    function exchangeToken(address from, uint256 amount) external {
        if (from == address(firstToken)) {
            _exchangeFirstToken(amount);
        } else if (from == address(secondToken)) {
            _exchangeSecondToken(amount);
        } else {
            revert("ExchangeableToken: invalid token");
        }
    }

    function _exchangeFirstToken(uint256 amount) internal {
        firstToken.transferFrom(msg.sender, address(this), amount);

        uint256 secondTokenAmount = (amount * rate) / RATE_DECIMALS;
        secondToken.mint(msg.sender, secondTokenAmount);
    }

    function _exchangeSecondToken(uint256 amount) internal {
        secondToken.transferFrom(msg.sender, address(this), amount);

        uint256 firstTokenAmount = (amount * RATE_DECIMALS) / rate;
        firstToken.mint(msg.sender, firstTokenAmount);
    }
}
