// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../libraries/UniswapV2Library.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IAlphacadoChainRegistry.sol";
import "../adapters/AdapterBase.sol";
import {TokenSender, TokenReceiver, TokenBase} from "../../wormhole-solidity-sdk/src/TokenBase.sol";

import "hardhat/console.sol";
error CallSuccess();

contract MockAlphacado is TokenSender, TokenReceiver {
    uint256 private _requestId;
    uint256 constant GAS_LIMIT = 250_000;

    address public immutable USDC;
    uint16 public immutable CHAIN_ID;
    IAlphacadoChainRegistry public immutable registry;

    constructor(
        address _registry,
        address _USDC,
        uint16 _chainId,
        address _wormholeRelayer,
        address _tokenBridge,
        address _wormhole
    ) TokenBase(_wormholeRelayer, _tokenBridge, _wormhole) {
        USDC = _USDC;
        CHAIN_ID = _chainId;
        registry = IAlphacadoChainRegistry(_registry);
    }

    event CrossChainDepositSent(
        uint256 requestId,
        uint16 targetChain,
        uint16 targetChainActionId,
        uint256 USDCAmount,
        address sender,
        address recipient
    );
    event CrossChainDepositReceived(
        uint256 sourceChainRequestId,
        uint16 sourceChainId,
        uint16 actionId
    );

    function sendCrossChainRequest(
        address sender,
        uint16 targetChain,
        uint16 targetChainActionId,
        address receipient,
        uint256 amountUSDC,
        bytes calldata payload
    ) public {
        uint256 requestId = ++_requestId;

        bytes memory packedPayload = abi.encode(
            CHAIN_ID,
            requestId,
            targetChainActionId,
            receipient,
            payload
        );

        _sendCrossChainDeposit(
            targetChain,
            receipient,
            amountUSDC,
            USDC,
            packedPayload
        );

        emit CrossChainDepositSent(
            requestId,
            targetChain,
            targetChainActionId,
            amountUSDC,
            sender,
            receipient
        );
    }

    function quoteCrossChainDeposit(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        // Cost of delivering token and payload to targetChain
        uint256 deliveryCost;
        (deliveryCost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );

        // Total cost: delivery cost + cost of publishing the 'sending token' wormhole message
        cost = deliveryCost + wormhole.messageFee();
    }

    function _sendCrossChainDeposit(
        uint16 targetChain,
        address targetChainRecipient,
        uint256 amount,
        address token,
        bytes memory payload
    ) internal {
        revert CallSuccess();
    }

    function receivePayloadAndTokensMock(
        bytes memory payload,
        uint256 amount
    ) external onlyWormholeRelayer {
        TokenReceived[] memory receivedTokens = new TokenReceived[](1);
        receivedTokens[0] = TokenReceived(
            bytes32(0),
            uint16(0),
            USDC,
            amount,
            amount / (10e10)
        );
        receivePayloadAndTokens(
            payload,
            receivedTokens,
            bytes32(0),
            uint16(0),
            bytes32(0)
        );
    }

    function receivePayloadAndTokens(
        bytes memory payload,
        TokenReceived[] memory receivedTokens,
        bytes32, // sourceAddress
        uint16,
        bytes32 // deliveryHash
    ) internal override onlyWormholeRelayer {
        require(receivedTokens.length == 1, "Expected 1 token transfers");
        require(receivedTokens[0].tokenAddress == USDC, "Expected USDC token");

        (
            uint16 sourceChainId,
            uint256 sourceChainRequestId,
            uint16 actionId,
            address recipient,
            bytes memory actionPayload
        ) = abi.decode(payload, (uint16, uint256, uint16, address, bytes));

        address adapter = registry.getAdapter(actionId);

        IERC20(receivedTokens[0].tokenAddress).transfer(
            adapter,
            receivedTokens[0].amount
        );

        AdapterBase(adapter).executeReceived(
            receivedTokens[0].tokenAddress,
            receivedTokens[0].amount,
            recipient,
            actionPayload
        );

        emit CrossChainDepositReceived(
            sourceChainRequestId,
            sourceChainId,
            actionId
        );
    }
}
