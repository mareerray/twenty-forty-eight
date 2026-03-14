import 'package:flutter/material.dart';

class TileData {
  final int value;
  final int row;
  final int col;
  final String id; // unique ID so Flutter can track each tile

  TileData({required this.value, required this.row, required this.col, required this.id});
}
// Each tile now has an identity (id), so Flutter knows "this is the same tile, just moved."

Color getTileColor(int value) {
  switch (value) {
    case 2: return const Color(0xFF8c80a2);
    case 4: return const Color(0xFF51577c);
    case 8: return const Color(0xFF764a7d);
    case 16: return const Color(0xFF512DA8);
    case 32: return const Color(0xFF7338B7);
    case 64: return const Color(0xFF4F2E54);
    case 128: return const Color(0xFF7b1fa2);
    case 256: return const Color(0xFF4a148c);
    case 512: return const Color(0xFF880e4f);
    case 1024: return const Color(0xFFad1457);
    case 2048: return const Color(0xFFc2185b);
    default: return const Color(0xFFCCCCCC);
    // #5d4a7d, #6a7d4a, #764a7d, #4a517d
  }
}
