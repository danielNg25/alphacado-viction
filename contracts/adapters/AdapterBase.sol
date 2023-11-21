// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../interfaces/IAlphacado.sol";

abstract contract AdapterBase {
    IAlphacado public alphacado;

    constructor(address _alphacado) {
        alphacado = IAlphacado(_alphacado);
    }

    function executeReceived(
        address token,
        uint256 amount,
        address receipient,
        bytes memory payload
    ) external virtual;
}
