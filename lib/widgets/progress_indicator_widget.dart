import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int completed;
  final int total;
  final bool showLabel;
  final double height;

  const ProgressIndicatorWidget({
    Key? key,
    required this.completed,
    required this.total,
    this.showLabel = true,
    this.height = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ความคืบหน้า',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: completed / total,
            minHeight: height,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(percentage),
            ),
          ),
        ),
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'ตรวจแล้ว $completed/$total จุด',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) {
      return AppConfig.successColor;
    } else if (percentage >= 50) {
      return AppConfig.primaryColor;
    } else {
      return AppConfig.warningColor;
    }
  }
}