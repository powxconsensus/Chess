// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./ChessBoard.sol";
import "./Player.sol";

contract ChessGame {
    address public owner;
    enum GAME_STATUS {
        PAUSED,
        ACTIVE,
        BLACK_WIN,
        WHITE_WIN,
        FORFEIT,
        STALEMATE,
        RESIGNED
    }
    GAME_STATUS gameStatus;
    Player[2] public player;
    uint256 playerTurnIdx;
    ChessBoard public chessBoard;
    address public resignedBy;
    uint256 public startedAt;

    modifier isValidCoor(uint256 _x, uint256 _y) {
        require(_x >= 0 && _x < 8 && _y >= 0 && _y < 8, "INVALID CORD");
        _;
    }

    constructor(address player1, address player2) {
        player[0] = new Player(player1, true);
        player[1] = new Player(player2, false);
        playerTurnIdx = 0;
        chessBoard = new ChessBoard();
        startedAt = block.timestamp;
        owner = msg.sender;
        gameStatus = GAME_STATUS.PAUSED;
    }

    function startGame() public {
        require(msg.sender == owner, "action not allowed");
        require(gameStatus >= GAME_STATUS.ACTIVE, "game already started");
        gameStatus = GAME_STATUS.ACTIVE;
    }

    function moveAPiece(
        uint256 sx,
        uint256 sy,
        uint256 ex,
        uint256 ey
    ) public isValidCoor(sx, sy) isValidCoor(ex, ey) {
        require(gameStatus == GAME_STATUS.ACTIVE, "Game not started yet");
        require(
            player[playerTurnIdx].getPlayerAddress() == msg.sender,
            "You are not a game participant or not your turn"
        );
        Piece pieceAtS = chessBoard.getPiecesAtCoor(sx, sy);
        require(pieceAtS != Piece(address(0)), "select piece to move");
        Piece pieceAtE = chessBoard.getPiecesAtCoor(ex, ey);
        if (
            pieceAtS.canMove(
                pieceAtS,
                pieceAtE,
                ex,
                ey,
                player[playerTurnIdx],
                chessBoard
            )
        ) {
            if (pieceAtE != Piece(address(0))) {
                pieceAtE.setKilled(true);
            }
            chessBoard.move(pieceAtS, ex, ey);
            //after each move check is this checkmate condition for opponent
            (bool checkmate, Piece byPiece) = chessBoard.checkmateCheck(
                player,
                (0 == playerTurnIdx),
                chessBoard
            );
            if (checkmate) {
                if (
                    chessBoard.resolveCheckMate(
                        player[0],
                        player[1],
                        (0 == playerTurnIdx),
                        chessBoard
                    )
                ) {
                    // emit event regarding checkmate here byPiece
                } else {
                    // emit opponent lost the game
                }
            }

            // switch turn
            playerTurnIdx = (playerTurnIdx + 1) % 2;
        } else revert("Invalid Move");
    }

    function getPieceAtIndex(uint256 _x, uint256 _y)
        public
        view
        returns (Piece)
    {
        return chessBoard.getPiecesAtCoor(_x, _y);
    }

    function getPlayerColor(uint256 _x, uint256 _y) public view returns (bool) {
        return getPieceAtIndex(_x, _y).isWhite();
    }

    function resignGame() public {
        require(
            (player[0].getPlayerAddress() == msg.sender ||
                player[1].getPlayerAddress() == msg.sender),
            "Action not allowed"
        );
        require(
            gameStatus == GAME_STATUS.ACTIVE,
            "game already over or didn't started"
        );

        resignedBy = msg.sender;
        gameStatus = GAME_STATUS.RESIGNED;
    }
}
