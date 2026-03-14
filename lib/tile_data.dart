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
    // 🔰 Beyond 2048 — getting rarer and more golden/bright
    case 4096: return const Color(0xFFe91e63);
    case 8192: return const Color(0xFFff5722);
    case 16384: return const Color(0xFFff9800);
    case 32768: return const Color(0xFFffc107);
    case 65536: return const Color(0xFFffeb3b);
    default: return const Color(0xFFCCCCCC); // fallback for anything unexpected  
  }
}
