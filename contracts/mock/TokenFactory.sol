// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ExchangeableSourceChainERC20.sol";
import "./ExchangeableTargetChainERC20.sol";
import "./ExchangeToken.sol";

contract TokenFactory {
    enum TokenType {
        SourceChain,
        TargetChain,
        Exchange
    }

    mapping(uint256 => address) public tokens;
    mapping(uint256 => TokenType) public tokenTypes;
    uint256 public tokenCount;

    function createSourceChainToken(
        string memory name,
        string memory symbol,
        address exchangeToken,
        uint256 rate
    ) external returns (address token) {
        token = address(
            new ExchangeableSourceChainERC20(name, symbol, exchangeToken, rate)
        );
        tokens[tokenCount] = token;
        tokenTypes[tokenCount] = TokenType.SourceChain;
        tokenCount++;
    }

    function createTargetChainToken(
        string memory name,
        string memory symbol,
        address exchangeToken,
        uint256 rate
    ) external returns (address token) {
        token = address(
            new ExchangeableTargetChainERC20(name, symbol, exchangeToken, rate)
        );
        tokens[tokenCount] = token;
        tokenTypes[tokenCount] = TokenType.TargetChain;
        tokenCount++;
    }

    function createExchangeToken(
        address firstToken,
        address secondToken,
        uint256 rate
    ) external returns (address token) {
        token = address(new ExchangeableToken(firstToken, secondToken, rate));
        tokens[tokenCount] = token;
        tokenTypes[tokenCount] = TokenType.Exchange;
        tokenCount++;
    }
}
