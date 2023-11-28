// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../Vault.sol";
import "../../interfaces/stakely/IStakely.sol";
import "../../interfaces/stakely/IWrapStakely.sol";
import "../../interfaces/IWrapKlay.sol";
import "../../adapters/uniswap/UniswapV2LpAdapter.sol";

contract StakelyKlayswapVault is Vault {
    IStakely public stakely;
    IWrapStakely public wrapStakely;
    UniswapV2LpAdapter public adapter;
    IUniswapV2Router02 public router;
    IUniswapV2Pair pair;

    struct StrategyInfo {
        uint256 totalWrappedStakely;
        uint256 totalLiquidity;
    }

    mapping(address => StrategyInfo) public strategies;

    constructor(
        string memory _name,
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _poolLimitPerUser,
        uint256 _depositFee,
        address _feeToAddress,
        IStakely _stakely,
        IWrapStakely _wrapStakely,
        UniswapV2LpAdapter _adapter,
        IUniswapV2Router02 _router,
        IUniswapV2Pair _pair
    )
        Vault(
            _name,
            _stakedToken,
            _rewardToken,
            _rewardPerBlock,
            _startBlock,
            _bonusEndBlock,
            _poolLimitPerUser,
            _depositFee,
            _feeToAddress
        )
    {
        stakely = _stakely;
        wrapStakely = _wrapStakely;
        adapter = _adapter;
        router = _router;
        pair = _pair;
    }

    function _onDeposit(uint256 _amount, address onBehalfOf) internal override {
        IERC20(stakedToken).transferFrom(msg.sender, address(this), _amount);

        uint256 toStakelyAmount = _amount / 2;
        IWrapKlay(address(stakedToken)).withdraw(toStakelyAmount);

        uint256 stakelyAmount = stakely.getSharesByKlay(toStakelyAmount);
        stakely.stake{value: toStakelyAmount}();

        stakely.approve(address(wrapStakely), stakelyAmount);

        uint256 wrapStakelyAmount = wrapStakely.getWrappedAmount(stakelyAmount);
        wrapStakely.wrap(stakelyAmount);

        uint256 klaySwapAmount = _amount - toStakelyAmount;
        IERC20(address(pair)).approve(address(adapter), klaySwapAmount);

        uint256 liquidity = adapter.zapIn(
            router,
            pair,
            address(stakedToken),
            address(this),
            klaySwapAmount,
            0,
            ""
        );

        StrategyInfo memory strategyInfo = strategies[onBehalfOf];

        strategyInfo.totalWrappedStakely += wrapStakelyAmount;
        strategyInfo.totalLiquidity += liquidity;

        strategies[onBehalfOf] = strategyInfo;
    }

    function _onWithdraw(
        uint256 _amount,
        address onBehalfOf
    ) internal override {
        StrategyInfo memory strategyInfo = strategies[onBehalfOf];

        uint256 _amount_bps = (_amount * 10000) / userInfo[onBehalfOf].amount;

        uint256 wrapStakelyAmount = (strategyInfo.totalWrappedStakely *
            _amount_bps) / 10000;

        uint256 stakelyAmount = wrapStakely.getUnwrappedAmount(
            wrapStakelyAmount
        );
        wrapStakely.unwrap(wrapStakelyAmount);

        uint256 klayStakedAmount = stakely.getKlayByShares(stakelyAmount);
        stakely.unstake(klayStakedAmount);

        IWrapKlay(address(stakedToken)).deposit{value: klayStakedAmount}();

        uint256 liquidity = (strategyInfo.totalLiquidity * _amount_bps) / 10000;

        IERC20(address(pair)).approve(address(adapter), liquidity);

        uint256 klayZapOutAmount = adapter.zapOut(
            router,
            pair,
            liquidity,
            address(stakedToken),
            0,
            ""
        );

        stakedToken.transfer(
            msg.sender,
            klayZapOutAmount + klayStakedAmount - _amount
        );
    }
}
