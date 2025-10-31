class SessionModel {
  final int id;
  final int userId;
  final int organizationId;
  final String status;
  final int totalCheckpoints;
  final int completedCheckpoints;
  final String createdAt;
  final String? completedAt;
  final List<int> completedCheckpointIds;

  SessionModel({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.status,
    required this.totalCheckpoints,
    required this.completedCheckpoints,
    required this.createdAt,
    this.completedAt,
    this.completedCheckpointIds = const [],
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      organizationId: json['organization_id'] as int,
      status: json['status'] as String,
      totalCheckpoints: json['total_checkpoints'] as int? ?? 0,
      completedCheckpoints: json['completed_checkpoints'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
      completedCheckpointIds: (json['completed_checkpoint_ids'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'status': status,
      'total_checkpoints': totalCheckpoints,
      'completed_checkpoints': completedCheckpoints,
      'created_at': createdAt,
      'completed_at': completedAt,
      'completed_checkpoint_ids': completedCheckpointIds,
    };
  }

  // Status getters
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Progress calculation
  double get progressPercentage {
    if (totalCheckpoints == 0) return 0;
    return (completedCheckpoints / totalCheckpoints) * 100;
  }

  // Check if all checkpoints are completed
  bool get isAllCompleted => completedCheckpoints >= totalCheckpoints;

  // Check if specific checkpoint is completed
  bool isCheckpointCompleted(int checkpointId) {
    return completedCheckpointIds.contains(checkpointId);
  }

  // Session code for display
  String get sessionCode => 'S${id.toString().padLeft(6, '0')}';

  // Start time (from created_at)
  String get startTime {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  // Formatted created date
  String get formattedCreatedDate {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '-';
    }
  }

  // Formatted created datetime
  String get formattedCreatedDateTime {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  // Duration (if completed)
  String? get duration {
    if (completedAt == null) return null;

    try {
      final start = DateTime.parse(createdAt);
      final end = DateTime.parse(completedAt!);
      final diff = end.difference(start);

      if (diff.inHours > 0) {
        return '${diff.inHours} ชม. ${diff.inMinutes % 60} นาที';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} นาที';
      } else {
        return '${diff.inSeconds} วินาที';
      }
    } catch (e) {
      return null;
    }
  }
}