import 'package:chess/features/chess_board/service/chess_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/piece.dart';
import '../model/square.dart';

// Provider for the main chess game state
final chessGameProvider = Provider((ref) => ChessGame());

// Provider to manage selected square state
final selectedSquareProvider = StateProvider<Square?>((ref) => null);

// Providers to manage captured pieces for each color
final capturedWhitePiecesProvider = StateProvider<List<Piece>>((ref) => []);
final capturedBlackPiecesProvider = StateProvider<List<Piece>>((ref) => []);

enum PlayerTurn { white, black }

final playerTurnProvider = StateProvider<PlayerTurn>((ref) => PlayerTurn.white);
