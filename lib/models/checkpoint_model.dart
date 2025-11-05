// lib/models/checkpoint_model.dart

class CheckpointModel {
  final int id;
  final String checkpointCode;
  final String checkpointName;
  final String description;
  final String locationDetail;
  final int sequenceOrder;
  final bool isRequired;
  final bool requirePhoto;
  final String status;
  final int nfcTagCount;
  final List<String> nfcTags;

  CheckpointModel({
    required this.id,
    required this.checkpointCode,
    required this.checkpointName,
    required this.description,
    required this.locationDetail,
    required this.sequenceOrder,
    required this.isRequired,
    required this.requirePhoto,
    required this.status,
    required this.nfcTagCount,
    required this.nfcTags,
  });

  factory CheckpointModel.fromJson(Map<String, dynamic> json) {
    return CheckpointModel(
      id: json['id'] ?? 0,
      checkpointCode: json['checkpoint_code'] ?? '',
      checkpointName: json['checkpoint_name'] ?? '',
      description: json['description'] ?? '',
      locationDetail: json['location_detail'] ?? '',
      sequenceOrder: json['sequence_order'] ?? 0,
      isRequired: json['is_required'] == 1 || json['is_required'] == true,
      requirePhoto: json['require_photo'] == 1 || json['require_photo'] == true,
      status: json['status'] ?? 'active',
      nfcTagCount: json['nfc_tag_count'] ?? 0,
      nfcTags: json['nfc_tags'] != null 
          ? List<String>.from(json['nfc_tags']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkpoint_code': checkpointCode,
      'checkpoint_name': checkpointName,
      'description': description,
      'location_detail': locationDetail,
      'sequence_order': sequenceOrder,
      'is_required': isRequired,
      'require_photo': requirePhoto,
      'status': status,
      'nfc_tag_count': nfcTagCount,
      'nfc_tags': nfcTags,
    };
  }
}

class CheckpointStatistics {
  final int total;
  final int required;
  final int optional;

  CheckpointStatistics({
    required this.total,
    required this.required,
    required this.optional,
  });

  factory CheckpointStatistics.fromJson(Map<String, dynamic> json) {
    return CheckpointStatistics(
      total: json['total'] ?? 0,
      required: json['required'] ?? 0,
      optional: json['optional'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'required': required,
      'optional': optional,
    };
  }
}