import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookTakeawayCard extends StatelessWidget {
  final String quote;
  final DateTime date;
  final int cardIndex;
  final VoidCallback? onTap;

  const BookTakeawayCard({
    super.key,
    required this.quote,
    required this.date,
    required this.cardIndex,
    this.onTap,
  });

  static const _dateFormat = 'd MMM yyyy';

  @override
  Widget build(BuildContext context) {
    final palette = _CardPalette.forIndex(cardIndex, context);
    final decor = _CardDecor.forIndex(cardIndex);
    final formattedDate = DateFormat(_dateFormat).format(date.toLocal());

    return Material(
      color: palette.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: palette.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: palette.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -24,
                  child: Icon(
                    decor.primaryIcon,
                    size: 120,
                    color: palette.watermarkColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u201C$quote\u201D',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            color: palette.quoteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: palette.dateColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardDecor {
  final IconData primaryIcon;

  const _CardDecor({required this.primaryIcon});

  static const _decors = [
    _CardDecor(primaryIcon: Icons.menu_book_rounded),
    _CardDecor(primaryIcon: Icons.auto_stories_outlined),
    _CardDecor(primaryIcon: Icons.import_contacts_outlined),
    _CardDecor(primaryIcon: Icons.local_library_outlined),
    _CardDecor(primaryIcon: Icons.library_books_outlined),
  ];

  static _CardDecor forIndex(int index) => _decors[index % _decors.length];
}

class _CardPalette {
  final Gradient gradient;
  final Color quoteColor;
  final Color dateColor;
  final Color watermarkColor;
  final Color shadowColor;
  final Color transparent;

  const _CardPalette({
    required this.gradient,
    required this.quoteColor,
    required this.dateColor,
    required this.watermarkColor,
    required this.shadowColor,
    required this.transparent,
  });

  static _CardPalette forIndex(int index, BuildContext context) {
    return _palettes[index % _palettes.length](context);
  }

  static Color _watermark(BuildContext context, Color base) {
    return base.withAlpha(context._light ? 22 : 18);
  }

  static final List<_CardPalette Function(BuildContext)> _palettes = [
    (context) => _CardPalette(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: context._light
            ? [const Color(0xFFFFF8EE), const Color(0xFFFFECB3)]
            : [const Color(0xFF3D2E1A), const Color(0xFF2A1F12)],
      ),
      quoteColor: context._light
          ? const Color(0xFF4E342E)
          : const Color(0xFFFFF8E1),
      dateColor: context._light
          ? const Color(0xFF795548)
          : const Color(0xFFFFE0B2),
      watermarkColor: _watermark(context, const Color(0xFF8D6E63)),
      shadowColor: context._light
          ? const Color(0xFFF59E0B).withAlpha(30)
          : Colors.black.withAlpha(50),
      transparent: Colors.transparent,
    ),
    (context) => _CardPalette(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: context._light
            ? [const Color(0xFFF3F4FB), const Color(0xFFE0E4F5)]
            : [const Color(0xFF1E1F3A), const Color(0xFF2A2B4A)],
      ),
      quoteColor: context._light
          ? const Color(0xFF1A237E)
          : const Color(0xFFE8EAF6),
      dateColor: context._light
          ? const Color(0xFF3949AB)
          : const Color(0xFF9FA8DA),
      watermarkColor: _watermark(context, const Color(0xFF5C6BC0)),
      shadowColor: context._light
          ? const Color(0xFF6366F1).withAlpha(28)
          : Colors.black.withAlpha(50),
      transparent: Colors.transparent,
    ),
    (context) => _CardPalette(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: context._light
            ? [const Color(0xFFEEF7F5), const Color(0xFFD5EFEB)]
            : [const Color(0xFF0D3D38), const Color(0xFF1A524C)],
      ),
      quoteColor: context._light
          ? const Color(0xFF004D40)
          : const Color(0xFFE0F2F1),
      dateColor: context._light
          ? const Color(0xFF00695C)
          : const Color(0xFF80CBC4),
      watermarkColor: _watermark(context, const Color(0xFF00897B)),
      shadowColor: context._light
          ? const Color(0xFF14B8A6).withAlpha(28)
          : Colors.black.withAlpha(50),
      transparent: Colors.transparent,
    ),
    (context) => _CardPalette(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: context._light
            ? [const Color(0xFFFFF5F8), const Color(0xFFFCE4EC)]
            : [const Color(0xFF3D1F2A), const Color(0xFF2A1520)],
      ),
      quoteColor: context._light
          ? const Color(0xFF880E4F)
          : const Color(0xFFFCE4EC),
      dateColor: context._light
          ? const Color(0xFFAD1457)
          : const Color(0xFFF48FB1),
      watermarkColor: _watermark(context, const Color(0xFFEC4899)),
      shadowColor: context._light
          ? const Color(0xFFEC4899).withAlpha(28)
          : Colors.black.withAlpha(50),
      transparent: Colors.transparent,
    ),
    (context) => _CardPalette(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: context._light
            ? [const Color(0xFFF7F3FC), const Color(0xFFEDE7F6)]
            : [const Color(0xFF2A1F3D), const Color(0xFF1F1630)],
      ),
      quoteColor: context._light
          ? const Color(0xFF311B92)
          : const Color(0xFFEDE7F6),
      dateColor: context._light
          ? const Color(0xFF512DA8)
          : const Color(0xFFB39DDB),
      watermarkColor: _watermark(context, const Color(0xFF7E57C2)),
      shadowColor: context._light
          ? const Color(0xFF8B5CF6).withAlpha(28)
          : Colors.black.withAlpha(50),
      transparent: Colors.transparent,
    ),
  ];
}

extension on BuildContext {
  bool get _light => Theme.of(this).brightness == Brightness.light;
}
