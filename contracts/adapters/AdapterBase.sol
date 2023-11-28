// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../interfaces/IAlphacado.sol";
import "../interfaces/IAlphacadoChainRegistry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract AdapterBase {
    IAlphacado public alphacado;

    constructor(address _alphacado) {
        alphacado = IAlphacado(_alphacado);
    }

    function executeReceived(
        uint16 sourceChainId,
        uint256 sourceChainRequestId,
        address token,
        uint256 amount,
        address receipient,
        bytes memory payload
    ) external virtual;

    function _executeAction(
        uint16 sourceChainId,
        uint256 sourceChainRequestId,
        IAlphacadoChainRegistry chainRegistry,
        uint16 actionId,
        address token,
        uint256 amount,
        address receipient,
        bytes memory payload
    ) internal {
        address adapter = chainRegistry.getAdapter(actionId);

        IERC20(token).transfer(adapter, amount);

        AdapterBase(adapter).executeReceived(
            sourceChainId,
            sourceChainRequestId,
            token,
            amount,
            receipient,
            payload
        );
    }
}
