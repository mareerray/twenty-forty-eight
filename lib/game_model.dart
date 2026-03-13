import 'dart:math';
// core game logic: swipe moves, tile sliding, merging, scoring, and new tiles.
// Grid is a 4x4 box of empty spots (null). startGame() clears it and adds 2 random tiles (2 or 4).

class GameModel {
  static const int gridSize = 4;
  List<List<int?>> grid = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));

  int score = 0;
  int bestScore = 0;

  GameModel() {
    startGame();
  }

  void startGame() {
    grid = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));
    score = 0;
    addRandomTile();
    addRandomTile();
    addRandomTile();
  }

  bool moveLeft() {
    bool moved = false;

    for (int i = 0; i < gridSize; i++) {
      // Step 1: Compress (push all non-null to the left)
      List<int?> row = grid[i].where((v) => v != null).toList();
      while (row.length < gridSize) {
        row.add(null);
      }

      // Step 2: Merge once — each tile merges at most once
      List<bool> merged = List.filled(gridSize, false);
      for (int j = 0; j < gridSize - 1; j++) {
        if (row[j] != null && row[j] == row[j + 1] && !merged[j]) {
          int val = row[j]! * 2;
          score += val;
          row[j] = val;
          row[j + 1] = null;
          merged[j] = true; // ✅ Mark as merged so it can't merge again
        }
      }

      // Step 3: Compress again (fill gaps left by merging)
      List<int?> newRow = row.where((v) => v != null).toList();
      while (newRow.length < gridSize) {
        newRow.add(null);
      }
      // Check if the row actually changed
      if (grid[i].join() != newRow.join()) moved = true;
      grid[i] = newRow;
    }

    if (moved) addRandomTile();
    if (score > bestScore) bestScore = score;
    return moved;
  }

  // ✅ RIGHT: reverse each row, moveLeft, reverse back
  bool moveRight() {
    _reverseRows();
    bool moved = moveLeft();
    _reverseRows();
    return moved;
  }

  // ✅ UP: transpose, moveLeft, transpose back
  bool moveUp() {
    _transpose();
    bool moved = moveLeft();
    _transpose();
    return moved;
  }

  // ✅ DOWN: transpose, moveRight (= reverse+moveLeft+reverse), transpose back
  bool moveDown() {
    _transpose();
    bool moved = moveRight();
    _transpose();
    return moved;
  }

  // Flip each row horizontally: [1,2,3,4] → [4,3,2,1]
  void _reverseRows() {
    for (int i = 0; i < gridSize; i++) {
      grid[i] = grid[i].reversed.toList();
    }
  }

  // Swap rows and columns: grid[i][j] ↔ grid[j][i]
  void _transpose() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = i + 1; j < gridSize; j++) {
        int? temp = grid[i][j];
        grid[i][j] = grid[j][i];
        grid[j][i] = temp;
      }
    }
  }

  void addRandomTile() {
    print('Adding ONE new tile...');
    List<int> emptyIndices = [];
    for (int i = 0; i < gridSize * gridSize; i++) {
      int row = i ~/ gridSize;
      int col = i % gridSize;
      if (grid[row][col] == null) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      int randomIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
      int row = randomIndex ~/ gridSize;
      int col = randomIndex % gridSize;
      grid[row][col] = (Random().nextDouble() < 0.9) ? 2 : 4; // New tiles are 90% 2's and 10% 4's
    }
  }

  bool get gameOver {
    // Check if full and no adjacent equals
    bool full = true;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == null) full = false;
      }
    }
    if (!full) return false;
    
    // Check adjacent
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (grid[i][j] == grid[i][j + 1] || grid[j][i] == grid[j + 1][i]) return false;
      }
    }
    return true;
  }

    String gridToString() {
    return grid
        .map((row) => row.map((e) => e?.toString() ?? '.').join('|'))
        .join('\n');
  }
}
