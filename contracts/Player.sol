// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Player {
    bool white = false;
    address playerAdd;

    constructor(address _playerAdd, bool _white) {
        playerAdd = _playerAdd;
        white = _white;
    }

    function isWhite() public view returns (bool) {
        return white;
    }

    function getPlayerAddress() public view returns (address) {
        return playerAdd;
    }
}
