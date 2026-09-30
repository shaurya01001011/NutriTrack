import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    double progress = current / target;

    if (progress > 1) {
      progress = 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              '${current.toInt()} / ${target.toInt()} g',
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          color: color,
          backgroundColor: color?.withValues(alpha: 0.2),
        ),
      ],
    );
  }
}