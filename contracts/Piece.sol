// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Player.sol";
import "./ChessBoard.sol";

//  pieces
abstract contract Piece {
    bool private killed = false;
    bool private white = false;
    uint256 x;
    uint256 y;
    modifier isValidCoor(uint256 _x, uint256 _y) {
        require(_x >= 0 && _x < 8 && _y >= 0 && _y < 8, "INVALID CORD");
        _;
    }

    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) isValidCoor(_x, _y) {
        white = _white;
        x = _x;
        y = _y;
    }

    function isWhite() public view returns (bool) {
        return white;
    }

    function isKilled() public view returns (bool) {
        return killed;
    }

    function setKilled(
        bool _killed,
        Player player,
        Piece piece
    ) public {
        require(!killed, "already killed");
        killed = _killed;
        player.removePiece(piece);
    }

    function getXY() public view returns (uint256, uint256) {
        return (x, y);
    }

    function setXY(uint256 _x, uint256 _y) public isValidCoor(_x, _y) {
        // check called from same board contract or not
        x = _x;
        y = _y;
    }

    modifier preIsMoveable(
        Piece pieceAtS,
        Piece pieceAtE,
        Player player
    ) {
        require(
            pieceAtS.isWhite() == player.isWhite(),
            "You are allowed to move pieces of your color!"
        );
        if (pieceAtE != Piece(address(0))) {
            require(
                player.isWhite() != pieceAtE.isWhite(),
                "INVALID MOVE: You cann't move to your piece position"
            );
        }
        _;
    }

    function horizontalAndVerticalMovement(
        ChessBoard chessBoard,
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y
    ) internal view returns (bool) {
        if (x == _x) {
            if (_y > y) {
                // -> -> ->
                for (uint256 i = y + 1; i < _y - 1; i++) {
                    if (chessBoard.getPiecesAtCoor(x, i) != Piece(address(0)))
                        return false;
                }
            } else {
                // <- <- <-
                for (uint256 i = y - 1; i >= _y + 1; i--) {
                    if (chessBoard.getPiecesAtCoor(x, i) != Piece(address(0)))
                        return false;
                }
            }
        }
        if (y == _y) {
            if (_x > x) {
                // -> -> -> downwards
                for (uint256 i = x + 1; i < _x - 1; i++) {
                    if (chessBoard.getPiecesAtCoor(i, y) != Piece(address(0)))
                        return false;
                }
            } else {
                // <- <- <- upwards
                for (uint256 i = x - 1; i >= _x + 1; i--) {
                    if (chessBoard.getPiecesAtCoor(i, y) != Piece(address(0)))
                        return false;
                }
            }
        }
        // at _x,_y
        if (pieceAtE == Piece(address(0)))
            // if it's empty
            return true;
        else {
            // not empty, therefore that piece will killed after move
            if (pieceAtE.isWhite() != pieceAtS.isWhite()) return true;
            return false;
        }
    }

    function diagonalMovement(
        ChessBoard chessBoard,
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y
    ) internal view returns (bool) {
        uint256 t_x = x;
        uint256 t_y = y;
        if (_x < x && _y > y) {
            // first quadrant
            t_x--;
            t_y++;
            while (t_x > _x) {
                if (chessBoard.getPiecesAtCoor(t_x, t_y) != Piece(address(0)))
                    return false;
                t_x--;
                t_y++;
            }
        }
        if (_x < x && _y < y) {
            // second quadrant
            t_x--;
            t_y--;
            while (t_x > _x) {
                if (chessBoard.getPiecesAtCoor(t_x, t_y) != Piece(address(0)))
                    return false;
                t_x--;
                t_y--;
            }
        }
        if (_x > x && _y < y) {
            // third quadrant
            t_x++;
            t_y--;
            while (t_x < _x) {
                if (chessBoard.getPiecesAtCoor(t_x, t_y) != Piece(address(0)))
                    return false;
                t_x++;
                t_y--;
            }
        }
        if (_x > x && _y > y) {
            // fourth quadrant
            t_x++;
            t_y++;
            while (t_x < _x) {
                if (chessBoard.getPiecesAtCoor(t_x, t_y) != Piece(address(0)))
                    return false;
                t_x++;
                t_y++;
            }
        }
        // at _x,_y
        if (pieceAtE == Piece(address(0)))
            // if it's empty
            return true;
        else {
            // not empty, therefore that piece will killed after move
            if (pieceAtE.isWhite() != pieceAtS.isWhite()) return true;
            return false;
        }
    }

    function isValidOneStepPosition(
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    ) internal view returns (bool) {
        Piece pieceAtE = chessBoard.getPiecesAtCoor(_x, _y);
        if (pieceAtE == Piece(address(0))) return true;
        if (pieceAtE.isWhite() == player.isWhite()) return false;
        return true;
    }

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    ) public virtual returns (bool);
}

contract Knight is Piece {
    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) Piece(_white, _x, _y) {}

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    )
        public
        view
        override
        preIsMoveable(pieceAtS, pieceAtE, player)
        returns (bool)
    {
        uint256 xd = (x > _x ? x - _x : _x - x);
        uint256 yd = (y > _y ? y - _y : _y - y);
        return xd * yd == 2;
    }
}

contract King is Piece {
    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) Piece(_white, _x, _y) {}

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    )
        public
        view
        override
        preIsMoveable(pieceAtS, pieceAtE, player)
        returns (bool)
    {
        uint256 xd = (x > _x ? x - _x : _x - x);
        uint256 yd = (y > _y ? y - _y : _y - y);
        require(xd <= 1 && yd <= 1, "can take only one step only");
        return isValidOneStepPosition(_x, _y, player, chessBoard);
    }
}

contract Queen is Piece {
    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) Piece(_white, _x, _y) {}

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    )
        public
        view
        override
        preIsMoveable(pieceAtS, pieceAtE, player)
        returns (bool)
    {
        return (diagonalMovement(chessBoard, pieceAtS, pieceAtE, _x, _y) ||
            horizontalAndVerticalMovement(
                chessBoard,
                pieceAtS,
                pieceAtE,
                _x,
                _y
            ));
    }
}

contract Pawn is Piece {
    bool firstMove = true;

    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) Piece(_white, _x, _y) {}

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    )
        public
        view
        override
        preIsMoveable(pieceAtS, pieceAtE, player)
        returns (bool)
    {
        require(
            ((_x > x && player.isWhite()) || (x < _x && !player.isWhite())),
            "Pawn can only move forward"
        );
        uint256 yd = (y > _y ? y - _y : _y - y);
        uint256 xd = (x > _x ? x - _x : _x - x);
        require((yd >= 0 && yd <= 1), "Pawn can only move up or diagonally");
        if (firstMove) {
            if (xd <= 2 && yd == 0) return true;
            return false;
        } else {
            if (xd == 1) {
                if (yd == 0) {
                    // trying to move forward, check there should not be any piece
                    if (pieceAtE != Piece(address(0))) return false;
                    return true;
                } else {
                    // trying to move diagonal, check there should be opposite color piece
                    if (pieceAtE == Piece(address(0))) return false;
                    return true;
                }
            }
            return false;
        }
    }
}

contract Rook is Piece {
    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) Piece(_white, _x, _y) {}

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    )
        public
        view
        override
        preIsMoveable(pieceAtS, pieceAtE, player)
        returns (bool)
    {
        require(
            (x == _x || y == _y),
            "can only move horizontally or vertically"
        );
        return
            horizontalAndVerticalMovement(
                chessBoard,
                pieceAtS,
                pieceAtE,
                _x,
                _y
            );
    }
}

contract Bishop is Piece {
    constructor(
        bool _white,
        uint256 _x,
        uint256 _y
    ) Piece(_white, _x, _y) {}

    function canMove(
        Piece pieceAtS,
        Piece pieceAtE,
        uint256 _x,
        uint256 _y,
        Player player,
        ChessBoard chessBoard
    )
        public
        view
        override
        preIsMoveable(pieceAtS, pieceAtE, player)
        returns (bool)
    {
        return diagonalMovement(chessBoard, pieceAtS, pieceAtE, _x, _y);
    }
}
