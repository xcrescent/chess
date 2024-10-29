import 'package:auto_route/auto_route.dart';
import 'package:chess/features/chess_board/controller/chess_pods.dart';
import 'package:chess/features/chess_board/model/piece.dart';
import 'package:chess/features/chess_board/model/square.dart';
import 'package:chess/features/chess_board/service/chess_logic.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage(deferredLoading: true)
class ChessBoardPage extends HookConsumerWidget {
  const ChessBoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.read(chessGameProvider);
    final capturedWhitePieces = ref.watch(capturedWhitePiecesProvider);
    final capturedBlackPieces = ref.watch(capturedBlackPiecesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chess Game',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              game.reset();
              ref.read(capturedWhitePiecesProvider.notifier).state = [];
              ref.read(capturedBlackPiecesProvider.notifier).state = [];
              ref.read(selectedSquareProvider.notifier).state = null;
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display captured pieces for Black
            _buildCapturedPiecesRow(capturedBlackPieces),
            // The chess board
            _buildChessBoard(ref, game, context),
            // Display captured pieces for White
            _buildCapturedPiecesRow(capturedWhitePieces),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(
      BuildContext context, int index, WidgetRef ref, ChessGame game) {
    int row = index ~/ 8;
    int col = index % 8;
    Square square = Square(row, col);
    Piece? piece = game.board.getPiece(square);
    Color backgroundColor =
        (row + col) % 2 == 0 ? Colors.brown[300]! : Colors.white;
    final selectedSquare = ref.watch(selectedSquareProvider);
    bool isHighlight =
        selectedSquare != null && game.isMoveValid(selectedSquare, square);
    return GestureDetector(
      onTap: () => _handleTap(ref, square, game, context),
      child: Container(
        color: selectedSquare?.col == square.col &&
                selectedSquare?.row == square.row
            ? Colors.yellow
            : isHighlight
                ? Colors.lightGreenAccent.withOpacity(0.5)
                : backgroundColor,
        child: Center(
          child: piece != null
              ? Text(
                  pieceToUnicode(piece),
                  style: TextStyle(
                    fontSize: 30,
                    color: piece.color == PieceColor.white
                        ? Colors.white
                        : Colors.black,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
              : Container(
                  color: isHighlight
                      ? Colors.white.withOpacity(0.5)
                      : Colors.transparent,
                ),
        ),
      ),
    );
  }

  String pieceToUnicode(Piece piece) {
    const pieceSymbols = {
      PieceType.pawn: '♟',
      PieceType.knight: '♞',
      PieceType.bishop: '♝',
      PieceType.rook: '♜',
      PieceType.queen: '♛',
      PieceType.king: '♚',
    };

    String symbol = pieceSymbols[piece.type] ?? '';

    return piece.color == PieceColor.white ? symbol.toUpperCase() : symbol;
  }

  void _handleTap(
      WidgetRef ref, Square square, ChessGame game, BuildContext context) {
    final selectedSquare = ref.read(selectedSquareProvider);
    final capturedWhitePieces = ref.read(capturedWhitePiecesProvider.notifier);
    final capturedBlackPieces = ref.read(capturedBlackPiecesProvider.notifier);
    final playerTurn = ref.read(playerTurnProvider);
    Piece? selectedPiece = game.board.getPiece(selectedSquare ?? square);
    if (playerTurn == PlayerTurn.white &&
        selectedPiece?.color == PieceColor.black) {
      debugPrint("Black's turn");
      return;
    }
    if (playerTurn == PlayerTurn.black &&
        selectedPiece?.color == PieceColor.white) {
      debugPrint("White's turn");
      return;
    }
    if (selectedSquare?.col == square.col &&
        selectedSquare?.row == square.row) {
      ref.read(selectedSquareProvider.notifier).state = null;
    } else if (selectedSquare == null) {
      if (game.board.getPiece(square) != null) {
        ref.read(selectedSquareProvider.notifier).state = square;
      }
    } else {
      if (game.isMoveValid(selectedSquare, square)) {
        print('Move is valid');
      } else {
        print('Move is invalid');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid move!'),
          ),
        );
        ref.read(selectedSquareProvider.notifier).state = null;

        return;
      }
      // Make a move and update state
      final piece = game.board.getPiece(square);
      if (piece != null && piece.color == PieceColor.white) {
        capturedWhitePieces.state = [...capturedWhitePieces.state, piece];
      } else if (piece != null && piece.color == PieceColor.black) {
        capturedBlackPieces.state = [...capturedBlackPieces.state, piece];
      }

      game.makeMove(selectedSquare, square);
      ref.read(selectedSquareProvider.notifier).state = null;
      // Toggle turn after move
      ref.read(playerTurnProvider.notifier).state =
          playerTurn == PlayerTurn.white ? PlayerTurn.black : PlayerTurn.white;
      // Check for check and checkmate
      if (game.isCheckmate(PieceColor.white)) {
        _showEndDialog(context, "White is checkmated!");
      } else if (game.isCheckmate(PieceColor.black)) {
        _showEndDialog(context, "Black is checkmated!");
      } else if (game.isKingInCheck(PieceColor.white)) {
        _showCheckDialog(context, "White king is in check!");
      } else if (game.isKingInCheck(PieceColor.black)) {
        _showCheckDialog(context, "Black king is in check!");
      }
    }
  }

  void _showEndDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showCheckDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Check!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard(WidgetRef ref, ChessGame game, BuildContext context) {
    // The board should be a square, so we use the shortest side of the screen
    final maxWidthOrHeight =
        MediaQuery.of(context).size.shortestSide - 16 - 56 - 100;
    return Container(
      width: maxWidthOrHeight,
      height: maxWidthOrHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) =>
            _buildSquare(context, index, ref, game),
        itemCount: 64,
      ),
    );
  }

  Widget _buildCapturedPiecesRow(List<Piece> pieces) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: pieces.map((piece) {
          return Container(
            margin: const EdgeInsets.all(4),
            child: Text(
              pieceToUnicode(piece),
              style: TextStyle(
                fontSize: 24,
                color: piece.color == PieceColor.white
                    ? Colors.white
                    : Colors.black,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
