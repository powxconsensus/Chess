// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Piece.sol";

contract Player {
    struct index {
        uint256 idx;
        bool isExist;
    }
    bool white = false;
    address playerAdd;

    Piece[] piecesOwn;
    mapping(Piece => index) indexMapping;

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

    function addPiece(Piece piece, uint256 idx) public {
        //condition check should be here, access restriction
        require(!indexMapping[piece].isExist, "Piece already exist");
        piecesOwn.push(piece);
        indexMapping[piece].isExist = true;
        indexMapping[piece].idx = idx;
    }

    function removePiece(Piece piece) public {
        require(indexMapping[piece].isExist, "Piece not found");
        piecesOwn[indexMapping[piece].idx] = piecesOwn[piecesOwn.length - 1];
        piecesOwn.pop();
        indexMapping[piece].isExist = false;
    }

    function getPieces() public view returns (Piece[] memory) {
        return piecesOwn;
    }
}
