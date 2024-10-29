import 'package:chess/features/chess_board/model/board.dart';
import 'package:chess/features/chess_board/model/piece.dart';
import 'package:chess/features/chess_board/model/square.dart';

class ChessGame {
  Board board;
  List<Piece> capturedWhitePieces = [];
  List<Piece> capturedBlackPieces = [];
  ChessGame() : board = Board();

  bool isMoveValid(Square from, Square to) {
    Piece? piece = board.getPiece(from);
    if (piece == null) return false;

    switch (piece.type) {
      case PieceType.pawn:
        return _isValidPawnMove(from, to, piece.color);
      case PieceType.knight:
        return _isValidKnightMove(from, to);
      case PieceType.bishop:
        return _isValidBishopMove(from, to);
      case PieceType.rook:
        return _isValidRookMove(from, to);
      case PieceType.queen:
        return _isValidQueenMove(from, to);
      case PieceType.king:
        return _isValidKingMove(from, to);
    }
  }

  bool _isValidPawnMove(Square from, Square to, PieceColor color) {
    int direction = color == PieceColor.white ? -1 : 1;
    int startRow = color == PieceColor.white ? 6 : 1;

    if (from.col == to.col) {
      if (from.row + direction == to.row && board.getPiece(to) == null) {
        return true; // Normal move
      }
      if (from.row == startRow &&
          from.row + 2 * direction == to.row &&
          board.getPiece(to) == null) {
        return true; // Double move from start
      }
    } else if ((from.col - to.col).abs() == 1 &&
        from.row + direction == to.row &&
        board.getPiece(to) != null &&
        board.getPiece(to)!.color != color) {
      return true; // Capture
    }
    return false;
  }

  bool _isValidKnightMove(Square from, Square to) {
    int dx = (from.col - to.col).abs();
    int dy = (from.row - to.row).abs();
    return dx * dy == 2; // L-shape movement
  }

  bool _isValidBishopMove(Square from, Square to) {
    return (from.row - to.row).abs() == (from.col - to.col).abs();
  }

  bool _isValidRookMove(Square from, Square to) {
    return from.row == to.row || from.col == to.col;
  }

  bool _isValidQueenMove(Square from, Square to) {
    return _isValidRookMove(from, to) || _isValidBishopMove(from, to);
  }

  bool _isValidKingMove(Square from, Square to) {
    int dx = (from.col - to.col).abs();
    int dy = (from.row - to.row).abs();
    return dx <= 1 && dy <= 1;
  }

  void makeMove(Square from, Square to) {
    if (isMoveValid(from, to)) {
      capturePiece(to);
      board.movePiece(from, to);
      print(
          "Move from ${from.row},${from.col} to ${to.row},${to.col} was successful.");
    } else {
      print(
          "Invalid move from ${from.row},${from.col} to ${to.row},${to.col}.");
    }
  }

  void capturePiece(Square square) {
    Piece? piece = board.getPiece(square);
    if (piece != null) {
      if (piece.color == PieceColor.white) {
        capturedWhitePieces.add(piece);
      } else {
        capturedBlackPieces.add(piece);
      }
    }
  }

  bool isKingInCheck(PieceColor color) {
    Square? kingSquare;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Square square = Square(row, col);
        Piece? piece = board.getPiece(square);
        if (piece?.type == PieceType.king && piece?.color == color) {
          kingSquare = square;
          break;
        }
      }
    }
    if (kingSquare == null) return false;

    // Check if any opponent piece can move to the king's square
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Square from = Square(row, col);
        Piece? piece = board.getPiece(from);
        if (piece != null &&
            piece.color != color &&
            isMoveValid(from, kingSquare)) {
          return true;
        }
      }
    }
    return false;
  }

  bool canCastle(PieceColor color, bool kingSide) {
    // Ensure king and rook are unmoved, spaces between them are empty, and the king is not in check
    // Example positions for white king and rooks (kingSide = true -> kingside, false -> queenside)
    Square kingSquare = color == PieceColor.white ? Square(7, 4) : Square(0, 4);
    Square rookSquare = color == PieceColor.white
        ? (kingSide ? Square(7, 7) : Square(7, 0))
        : (kingSide ? Square(0, 7) : Square(0, 0));

    // Checks omitted for brevity but would involve verifying empty spaces and check-free path

    return true;
  }

  void performCastle(PieceColor color, bool kingSide) {
    Square kingFrom = color == PieceColor.white ? Square(7, 4) : Square(0, 4);
    Square kingTo = color == PieceColor.white
        ? (kingSide ? Square(7, 6) : Square(7, 2))
        : (kingSide ? Square(0, 6) : Square(0, 2));
    Square rookFrom = color == PieceColor.white
        ? (kingSide ? Square(7, 7) : Square(7, 0))
        : (kingSide ? Square(0, 7) : Square(0, 0));
    Square rookTo = color == PieceColor.white
        ? (kingSide ? Square(7, 5) : Square(7, 3))
        : (kingSide ? Square(0, 5) : Square(0, 3));

    board.movePiece(kingFrom, kingTo);
    board.movePiece(rookFrom, rookTo);
  }

  bool isCheckmate(PieceColor color) {
    if (!isKingInCheck(color)) return false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Square from = Square(row, col);
        Piece? piece = board.getPiece(from);
        if (piece != null && piece.color == color) {
          for (int r = 0; r < 8; r++) {
            for (int c = 0; c < 8; c++) {
              Square to = Square(r, c);
              if (isMoveValid(from, to)) {
                // Simulate move
                Piece? capturedPiece = board.getPiece(to);
                board.movePiece(from, to);
                bool stillInCheck = isKingInCheck(color);
                // Undo move
                board.movePiece(to, from);
                if (capturedPiece != null) board.setPiece(to, capturedPiece);

                if (!stillInCheck) return false;
              }
            }
          }
        }
      }
    }
    return true;
  }

  void performEnPassant(Square from, Square to) {
    // Assuming `to` is the en passant target square
    board.movePiece(from, to);
    // Capture the pawn in en passant
    Square capturedPawnSquare = Square(from.row, to.col);
    board.setPiece(capturedPawnSquare, null);
  }

  void promotePawn(Square square, PieceType newType) {
    Piece? piece = board.getPiece(square);
    if (piece != null && piece.type == PieceType.pawn) {
      board.setPiece(square, Piece(newType, piece.color));
    }
  }

  void reset() {
    board = Board();
    capturedWhitePieces.clear();
    capturedBlackPieces.clear();
  }
}
