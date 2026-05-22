import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/models/custom_activity.dart';
import '../../settings/data/custom_activity_icon_storage.dart';

/// Material icon or 64×64 PNG for a [CustomActivity].
class ActivityIcon extends StatelessWidget {
  final CustomActivity activity;
  final double size;
  final Color? color;

  static final _storage = CustomActivityIconStorage();

  const ActivityIcon({
    super.key,
    required this.activity,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!activity.hasCustomIcon) {
      return _materialIcon();
    }

    return FutureBuilder<File?>(
      future: _storage.resolveFile(activity.customIconPath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _materialIcon(),
            ),
          );
        }
        return _materialIcon();
      },
    );
  }

  Widget _materialIcon() {
    return Icon(
      activity.icon,
      size: size,
      color: color ?? activity.color,
    );
  }
}
