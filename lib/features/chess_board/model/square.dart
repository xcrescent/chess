class Square {
  final int row;
  final int col;

  Square(this.row, this.col);

  bool isOnBoard() => row >= 0 && row < 8 && col >= 0 && col < 8;
}
