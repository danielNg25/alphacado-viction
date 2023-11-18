// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./libraries/UniswapV2Library.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./zapper/ZapperUniswapV2.sol";
import {TokenSender, TokenReceiver, TokenBase} from "../wormhole-solidity-sdk/src/TokenBase.sol";

contract Alphacado is ZapperUniswapV2, TokenSender, TokenReceiver {
    uint256 private _requestId;
    uint256 constant GAS_LIMIT = 250_000;
    IUniswapV2Router02 public immutable router;

    address public immutable USDC;

    constructor(
        address _router,
        address _USDC,
        address _wormholeRelayer,
        address _tokenBridge,
        address _wormhole
    ) TokenBase(_wormholeRelayer, _tokenBridge, _wormhole) {
        router = IUniswapV2Router02(_router);
        USDC = _USDC;
    }

    event CrossChainDepositSent(
        uint16 targetChain,
        uint256 requestId,
        uint256 liquidity,
        address tokenB,
        address targetChainTokenB,
        address recipient,
        address sender
    );

    event CrossChainDepositReceived(
        uint256 chainId,
        uint256 requestId,
        uint256 amountUSDC,
        address tokenB,
        uint256 receivedLiquidity,
        address recipient,
        address sender
    );

    function transferToken(
        address tokenB,
        uint256 liquidity,
        uint256 minimumSendAmount,
        uint16 targetChain,
        address targetChainTokenB,
        uint256 minimumReceiveLiquidity,
        address recipient
    ) public payable {
        address pair = UniswapV2Library.pairFor(router.factory(), USDC, tokenB);

        uint amountUSDC = zapOut(
            router,
            IUniswapV2Pair(pair),
            liquidity,
            USDC,
            minimumSendAmount,
            ""
        );

        uint256 chainId;

        assembly {
            chainId := chainid()
        }

        bytes memory payload = abi.encode(
            chainId,
            ++_requestId,
            amountUSDC,
            targetChainTokenB,
            minimumReceiveLiquidity,
            recipient,
            msg.sender
        );

        _sendCrossChainDeposit(
            targetChain,
            recipient,
            amountUSDC,
            USDC,
            payload
        );

        emit CrossChainDepositSent(
            targetChain,
            _requestId,
            liquidity,
            tokenB,
            targetChainTokenB,
            recipient,
            msg.sender
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
        uint256 cost = quoteCrossChainDeposit(targetChain);
        require(
            msg.value == cost,
            "msg.value must be quoteCrossChainDeposit(targetChain)"
        );

        sendTokenWithPayloadToEvm(
            targetChain,
            targetChainRecipient, // address (on targetChain) to send token and payload to
            payload,
            0, // receiver value
            GAS_LIMIT,
            token, // address of IERC20 token contract
            amount
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

        (
            uint256 chainId,
            uint256 requestId,
            uint256 amountUSDC,
            address tokenB,
            uint256 minimumReceiveLiquidity,
            address recipient,
            address sender
        ) = abi.decode(
                payload,
                (uint256, uint256, uint256, address, uint256, address, address)
            );

        address pair = UniswapV2Library.pairFor(router.factory(), USDC, tokenB);

        uint256 receivedLiquidity = zapIn(
            router,
            IUniswapV2Pair(pair),
            USDC,
            recipient,
            amountUSDC,
            minimumReceiveLiquidity,
            ""
        );

        emit CrossChainDepositReceived(
            chainId,
            requestId,
            amountUSDC,
            tokenB,
            receivedLiquidity,
            recipient,
            sender
        );
    }
}
