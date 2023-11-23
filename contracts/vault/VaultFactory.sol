// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Vault.sol";

contract VaultFactory is Ownable {
    event NewVault(address indexed vault);

    constructor() {
        //
    }

    /*
     * @notice Deploy the vault
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _endBlock: end block
     * @param _vaultLimitPerUser: vault limit per user in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     * @return address of new vault contract
     */
    function deployVault(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _vaultLimitPerUser,
        address _admin,
        uint256 _depositFee,
        address _feeToAddress
    ) external onlyOwner {
        require(_stakedToken.totalSupply() >= 0);
        require(_rewardToken.totalSupply() >= 0);
        require(_stakedToken != _rewardToken, "Tokens must be be different");

        bytes memory bytecode = type(Vault).creationCode;
        bytes32 salt = keccak256(
            abi.encodePacked(_stakedToken, _rewardToken, _startBlock)
        );
        address vaultAddress;

        assembly {
            vaultAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        Vault(vaultAddress).initialize(
            _stakedToken,
            _rewardToken,
            _rewardPerBlock,
            _startBlock,
            _bonusEndBlock,
            _vaultLimitPerUser,
            _admin,
            _depositFee,
            _feeToAddress
        );

        emit NewVault(vaultAddress);
    }
}
