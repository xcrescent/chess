import 'package:chess/features/chess_board/model/piece.dart';
import 'package:chess/features/chess_board/model/square.dart';

class Board {
  List<List<Piece?>> board;

  Board() : board = List.generate(8, (i) => List<Piece?>.filled(8, null)) {
    _initializeBoard();
  }

  void _initializeBoard() {
    // Place pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = Piece(PieceType.pawn, PieceColor.black);
      board[6][i] = Piece(PieceType.pawn, PieceColor.white);
    }

    // Place rooks
    board[0][0] = board[0][7] = Piece(PieceType.rook, PieceColor.black);
    board[7][0] = board[7][7] = Piece(PieceType.rook, PieceColor.white);

    // Place knights
    board[0][1] = board[0][6] = Piece(PieceType.knight, PieceColor.black);
    board[7][1] = board[7][6] = Piece(PieceType.knight, PieceColor.white);

    // Place bishops
    board[0][2] = board[0][5] = Piece(PieceType.bishop, PieceColor.black);
    board[7][2] = board[7][5] = Piece(PieceType.bishop, PieceColor.white);

    // Place queens
    board[0][3] = Piece(PieceType.queen, PieceColor.black);
    board[7][3] = Piece(PieceType.queen, PieceColor.white);

    // Place kings
    board[0][4] = Piece(PieceType.king, PieceColor.black);
    board[7][4] = Piece(PieceType.king, PieceColor.white);
  }

  Piece? getPiece(Square square) =>
      square.isOnBoard() ? board[square.row][square.col] : null;

  // Method to set a piece on a specific square
  void setPiece(Square square, Piece? piece) {
    board[square.row][square.col] = piece;
  }

  void movePiece(Square from, Square to) {
    if (getPiece(from) != null) {
      board[to.row][to.col] = board[from.row][from.col];
      board[from.row][from.col] = null;
    }
  }
}
