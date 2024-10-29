enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PieceColor { white, black }

class Piece {
  final PieceType type;
  final PieceColor color;

  Piece(this.type, this.color);

  @override
  String toString() => '${color == PieceColor.white ? 'W' : 'B'}$type';
}
