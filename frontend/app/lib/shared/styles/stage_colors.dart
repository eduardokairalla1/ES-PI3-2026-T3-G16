import 'package:flutter/material.dart';

Color stageColor(String stage) => switch (stage) {
  'new'       => const Color(0xFF1565C0),
  'operating' => const Color(0xFF2E7D32),
  'expanding' => const Color(0xFF6A1B9A),
  _           => Colors.black,
};
