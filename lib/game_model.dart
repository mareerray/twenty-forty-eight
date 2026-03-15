import 'dart:math';
import 'game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameModel {
  static const int gridSize = 4;
  GameState state = GameState.idle; // 🔰 starts idle

  List<List<Map<String, dynamic>?>> grid = List.generate(
    gridSize, (_) => List<Map<String, dynamic>?>.filled(gridSize, null)
  );

  int _nextId = 0; // 🔰 global counter — every new tile gets a unique number
  
  int score = 0;
  int bestScore = 0;

  GameModel() {
    startGame();
  }

  // 🔰 LOAD best score from device storage
  Future<void> loadBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;
    // print('📂 Loaded best score: $bestScore'); // if nothing saved yet, use 0
  }

  // 🔰 SAVE best score to device storage
  Future<void> saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', bestScore);
    // print('✅ Saved best score: $bestScore');
  }

  List<Map<String, dynamic>> getTiles() {
    List<Map<String, dynamic>> tiles = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] != null) {
          tiles.add({
            'value': grid[r][c]!['value'], 
            'id': grid[r][c]!['id'],   // 🔰 pass the stable ID through
            'row': r, 
            'col': c,'isMerged': grid[r][c]!['isMerged'] ?? false,
          });
        }
      }
    }
    return tiles;
  }

  void startGame() {
    grid = List.generate(gridSize, (_) => List<Map<String, dynamic>?>.filled(gridSize, null));
    score = 0;
    _nextId = 0;
    state = GameState.playing; // 🔰 ready to play
    addRandomTile();
    addRandomTile();
    addRandomTile();
  }

  bool moveLeft({bool addTile = true}) {
    bool moved = false;
    // didMerge = false;

    for (int i = 0; i < gridSize; i++) {
      // Step 1: Compress (push all non-null to the left)
      List<Map<String, dynamic>?> row = grid[i].where((v) => v != null).toList();
      while (row.length < gridSize) {
        row.add(null);
      }

      // Step 2: Merge once — each tile merges at most once
      List<bool> merged = List.filled(gridSize, false);
      for (int j = 0; j < gridSize - 1; j++) {
        if (row[j] != null && row[j + 1] != null &&
          row[j]!['value'] == row[j + 1]!['value'] && !merged[j]) {
          int val = row[j]!['value'] * 2;
          score += val;
          row[j] = {'value': val, 'id': row[j]!['id'],'isMerged': true}; // 🔰 keep the LEFT tile's ID
          row[j + 1] = null;
          merged[j] = true; // 🔰 Mark as merged so it can't merge again in the same swipe
        }
      }

      // Step 3: Compress again (fill gaps left by merging)
      List<Map<String, dynamic>?> newRow = row.where((v) => v != null).toList();
      while (newRow.length < gridSize) {
        newRow.add(null);
      }
      // Check if the row actually changed
    if (grid[i].map((t) => t?['value']).join() != newRow.map((t) => t?['value']).join()) {
      moved = true;
    }
      grid[i] = newRow;
    }

    if (moved && addTile) {
      addRandomTile();
    }
    return moved;
  }

  // 🔰 RIGHT: reverse each row, moveLeft, reverse back
  bool moveRight({bool addTile = true}) {
    _reverseRows();
    bool moved = moveLeft(addTile: addTile);
    _reverseRows();
    return moved;
  }

  // 🔰 UP: transpose, moveLeft, transpose back
  bool moveUp({bool addTile = true}) {
    _transpose();
    bool moved = moveLeft(addTile: addTile);
    _transpose();
    return moved;
  }

  // 🔰 DOWN: transpose, moveRight (= reverse+moveLeft+reverse), transpose back
  bool moveDown({bool addTile = true}) {
    _transpose();
    bool moved = moveRight(addTile: addTile);
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
        var temp = grid[i][j];
        grid[i][j] = grid[j][i];
        grid[j][i] = temp;
      }
    }
  }

  void addRandomTile() {
    // print('Adding ONE new tile...');

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
      int tileValue = (Random().nextDouble() < 0.9) ? 2 : 4;
      grid[row][col] = {'value': tileValue, 'id': _nextId++}; // 🔰 born with a stable ID    
    }
  }

  bool get gameOver {
    bool full = grid.every((row) => row.every((cell) => cell != null));
    if (!full) return false;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (grid[i][j]!['value'] == grid[i][j + 1]!['value']) return false;
        if (grid[j][i]!['value'] == grid[j + 1][i]!['value']) return false;
      }
    }
    return true;
  }
}
