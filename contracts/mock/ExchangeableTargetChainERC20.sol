// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MockERC20.sol";

contract ExchangeableTargetChainERC20 is ERC20 {
    IERC20 public exchangeToken;
    uint256 public constant RATE_DECIMALS = 10 ** 8;
    uint256 public rate;

    constructor(
        string memory name,
        string memory symbol,
        address _exchangeToken,
        uint256 _rate
    ) ERC20(name, symbol) {
        exchangeToken = IERC20(_exchangeToken);
        rate = _rate;
    }

    function mintNormally(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function mint(
        address to,
        uint256 exchangeTokenAmount
    ) external returns (uint256) {
        require(
            exchangeToken.balanceOf(address(this)) >= exchangeTokenAmount,
            "ExchangeableTargetChainERC20: insufficient balance"
        );

        exchangeToken.transfer(address(0), exchangeTokenAmount);

        uint256 amount = (exchangeTokenAmount * rate) / RATE_DECIMALS;

        _mint(to, amount);

        return amount;
    }
}
