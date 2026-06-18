import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/color_utils.dart';
import '../../../util/string_constant.dart';

class VaultPinPad extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String pin;
  final bool obscure;
  final bool isBusy;
  final String? errorMessage;
  final ValueChanged<String> onPinChanged;
  final VoidCallback? onBackspace;
  final VoidCallback? onSubmit;

  const VaultPinPad({
    super.key,
    required this.title,
    this.subtitle,
    required this.pin,
    this.obscure = true,
    this.isBusy = false,
    this.errorMessage,
    required this.onPinChanged,
    this.onBackspace,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 40, color: context.primary),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _PinDots(length: pin.length, maxLength: 6, obscure: obscure),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: context.danger),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isBusy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: _Keypad(onDigit: _appendDigit, onBackspace: _backspace),
              ),
          ],
        ),
      ),
    );
  }

  void _appendDigit(String digit) {
    if (pin.length >= 6) return;
    HapticFeedback.lightImpact();
    final next = pin + digit;
    onPinChanged(next);
    if (next.length == 6) {
      onSubmit?.call();
    }
  }

  void _backspace() {
    if (pin.isEmpty) return;
    HapticFeedback.lightImpact();
    onPinChanged(pin.substring(0, pin.length - 1));
    onBackspace?.call();
  }
}

class _PinDots extends StatelessWidget {
  final int length;
  final int maxLength;
  final bool obscure;

  const _PinDots({
    required this.length,
    required this.maxLength,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final filled = index < length;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? context.primary : context.transparent,
            border: Border.all(
              color: filled ? context.primary : context.borderMid,
              width: 2,
            ),
          ),
          child: filled && !obscure
              ? Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(fontSize: 8),
                  ),
                )
              : null,
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _Keypad({required this.onDigit, required this.onBackspace});

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossSpacing = 10.0;
        const mainSpacing = 10.0;
        const columns = 3;
        const rows = 4;

        final cellWidth =
            (constraints.maxWidth - crossSpacing * (columns - 1)) / columns;
        final cellHeight =
            (constraints.maxHeight - mainSpacing * (rows - 1)) / rows;
        final aspectRatio = cellWidth / cellHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: mainSpacing,
            crossAxisSpacing: crossSpacing,
            childAspectRatio: aspectRatio.clamp(0.8, 2.2),
          ),
          itemCount: _keys.length,
          itemBuilder: (context, index) {
            final key = _keys[index];
            if (key.isEmpty) return const SizedBox.shrink();
            final isBackspace = key == '⌫';
            return Material(
              color: context.bgCard,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => isBackspace ? onBackspace() : onDigit(key),
                child: Center(
                  child: Text(
                    key,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

String? vaultLockoutMessage(DateTime? lockoutUntil) {
  if (lockoutUntil == null) return null;
  final remaining = lockoutUntil.difference(DateTime.now());
  if (remaining.isNegative) return null;
  final seconds = remaining.inSeconds.clamp(1, 999);
  return AppStrings.vaultLockoutMessage(seconds);
}
