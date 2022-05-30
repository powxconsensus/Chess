// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Piece.sol";

contract ChessBoard {
    uint256 cnt = 0;
    Piece[8][8] public board;
    Piece kingPlayer1;
    Piece kingPlayer2;

    // ChessGame boardFor; // for access restriction
    constructor(Player[] memory player) {
        resetBoard(player);
    }

    function resetBoard(Player[] memory player) public {
        resetBoardPieces(true, 0, 1, player[0]);
        resetBoardPieces(false, 7, 6, player[1]);
        // reset other spaces
        for (uint256 i = 2; i < 6; i++) {
            for (uint256 j = 0; j < 8; j++) {
                board[i][j] = Piece(address(0));
            }
        }
    }

    function resetBoardPieces(
        bool isWhite,
        uint256 idx1,
        uint256 idx2,
        Player player
    ) internal {
        board[idx1][0] = new Rook(isWhite, 0, 0);
        board[idx1][7] = new Rook(isWhite, 0, 7);
        board[idx1][1] = new Knight(isWhite, 0, 1);
        board[idx1][6] = new Knight(isWhite, 0, 6);
        board[idx1][2] = new Bishop(isWhite, 0, 2);
        board[idx1][5] = new Bishop(isWhite, 0, 5);
        board[idx1][3] = new Queen(isWhite, 0, 3);
        board[idx1][4] = new King(isWhite, 0, 4);
        if (isWhite) kingPlayer1 = board[idx1][4];
        else kingPlayer2 = board[idx1][4];
        for (uint256 i = 0; i < 8; i++) {
            board[idx2][i] = new Pawn(isWhite, 1, i);
            player.addPiece(board[idx2][i], i);
            player.addPiece(board[idx1][i], i);
        }
    }

    function getPiecesAtCoor(uint256 x, uint256 y) public view returns (Piece) {
        return board[x][y];
    }

    function move(
        Piece piece,
        uint256 _x,
        uint256 _y
    ) public {
        // called from same game to which this board belongs
        (uint256 x, uint256 y) = piece.getXY();
        board[_x][_y] = board[x][y];
        piece.setXY(_x, _y);
        board[x][y] = Piece(address(0));
    }

    // isPlayer1 means who played last
    function checkmateCheck(
        Player[] memory player,
        bool isPlayer1,
        ChessBoard chessBoard
    ) public returns (bool, Piece) {
        // should be as view
        if (isPlayer1) {
            (uint256 ex, uint256 ey) = kingPlayer2.getXY();
            Piece[] memory pieces = player[0].getPieces();
            for (uint256 i = 0; i < pieces.length; i++) {
                if (
                    pieces[i].canMove(
                        pieces[i],
                        kingPlayer2,
                        ex,
                        ey,
                        player[0],
                        chessBoard
                    )
                ) return (true, pieces[i]);
            }
            return (false, Piece(address(0)));
        } else {
            (uint256 ex, uint256 ey) = kingPlayer1.getXY();
            Piece[] memory pieces = player[1].getPieces();
            for (uint256 i = 0; i < pieces.length; i++) {
                if (
                    pieces[i].canMove(
                        pieces[i],
                        kingPlayer1,
                        ex,
                        ey,
                        player[1],
                        chessBoard
                    )
                ) (true, pieces[i]);
            }
            return (false, Piece(address(0)));
        }
    }

    function isValidXY(uint256 _x, uint256 _y) internal pure returns (bool) {
        if (_x >= 0 && _x < 8 && _y >= 0 && _y < 8) return true;
        return false;
    }

    //TODO: Implement below function -> return weather opponent lost or not
    function resolveCheckMate(
        Player player1,
        Player player2,
        bool isPlayer1,
        ChessBoard chessBoard
    ) public view returns (bool) {
        // should be marked as view
        // Piece king;
        // if (isPlayer1) king = kingPlayer2;
        // else king = kingPlayer1;
        // (uint256 ox, uint256 oy) = king.getXY();
        // if (
        //     isValidXY(ox + 1, oy + 1) &&
        //     king.canMove(
        //         king,
        //         getPiecesAtCoor(ox + 1, oy + 1),
        //         ox + 1,
        //         oy + 1,
        //         (isPlayer1 ? player2 : player1),
        //         chessBoard
        //     )
        // ) {
        // }
        return true;
    }
}
