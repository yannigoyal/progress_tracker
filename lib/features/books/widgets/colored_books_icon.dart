import 'package:flutter/material.dart';

/// Stacked book spines — colors and initial derived from [bookName].
class ColoredBooksIcon extends StatelessWidget {
  final String bookName;

  const ColoredBooksIcon({super.key, required this.bookName});

  static const _spineSets = [
    [Color(0xFFE57373), Color(0xFF64B5F6), Color(0xFF81C784)],
    [Color(0xFFFFB74D), Color(0xFFBA68C8), Color(0xFF4DD0E1)],
    [Color(0xFF7986CB), Color(0xFFAED581), Color(0xFFFF8A65)],
    [Color(0xFFF06292), Color(0xFF9575CD), Color(0xFF4DB6AC)],
    [Color(0xFF90CAF9), Color(0xFFFFF176), Color(0xFFCE93D8)],
  ];

  static int paletteIndexFor(String bookName) {
    final normalized = bookName.trim().toLowerCase();
    if (normalized.isEmpty) return 0;
    var hash = 0;
    for (final unit in normalized.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return hash % _spineSets.length;
  }

  static String initialFor(String bookName) {
    final trimmed = bookName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _spineSets[paletteIndexFor(bookName)];
    final initial = initialFor(bookName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(12)
            : Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            bottom: 8,
            child: _BookSpine(color: colors[0], width: 10, height: 26),
          ),
          Positioned(
            left: 17,
            bottom: 6,
            child: _BookSpine(
              color: colors[1],
              width: 10,
              height: 30,
              label: initial,
            ),
          ),
          Positioned(
            left: 26,
            bottom: 9,
            child: _BookSpine(color: colors[2], width: 10, height: 24),
          ),
        ],
      ),
    );
  }
}

class _BookSpine extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final String? label;

  const _BookSpine({
    required this.color,
    required this.width,
    required this.height,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(1),
          bottomRight: Radius.circular(1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: label != null
          ? Center(
              child: Text(
                label!,
                style: TextStyle(
                  color: Colors.white.withAlpha(230),
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                width: width - 4,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(90),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
    );
  }
}
