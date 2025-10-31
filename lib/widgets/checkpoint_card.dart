import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/checkpoint_model.dart';

class CheckpointCard extends StatelessWidget {
  final CheckpointModel checkpoint;
  final VoidCallback onTap;
  final bool isCompleted;

  const CheckpointCard({
    super.key,
    required this.checkpoint,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppConfig.successColor
                  : Colors.grey.shade300,
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Sequence Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppConfig.successColor
                      : AppConfig.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        )
                      : Text(
                          '${checkpoint.sequenceOrder}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Checkpoint Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkpoint.checkpointName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkpoint.checkpointCode,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (checkpoint.locationDetail != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              checkpoint.locationDetail!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (checkpoint.isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppConfig.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'บังคับ',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppConfig.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (checkpoint.requirePhoto) ...[
                          if (checkpoint.isRequired) const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppConfig.infoColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 10,
                                  color: AppConfig.infoColor,
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  'ถ่ายรูป',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppConfig.infoColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: isCompleted
                    ? AppConfig.successColor
                    : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}