class CheckpointModel {
  final int id;
  final String checkpointCode;
  final String checkpointName;
  final String? description;
  final String? locationDetail;
  final int sequenceOrder;
  final bool isRequired;
  final bool requirePhoto;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> nfcTags;
  final int nfcTagCount;

  CheckpointModel({
    required this.id,
    required this.checkpointCode,
    required this.checkpointName,
    this.description,
    this.locationDetail,
    required this.sequenceOrder,
    required this.isRequired,
    required this.requirePhoto,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.nfcTags,
    required this.nfcTagCount,
  });

  factory CheckpointModel.fromJson(Map<String, dynamic> json) {
    return CheckpointModel(
      id: json['id'] ?? 0,
      checkpointCode: json['checkpoint_code'] ?? '',
      checkpointName: json['checkpoint_name'] ?? '',
      description: json['description'],
      locationDetail: json['location_detail'],
      sequenceOrder: json['sequence_order'] ?? 0,
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      requirePhoto: json['require_photo'] == true || json['require_photo'] == 1,
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'])
          : null,
      nfcTags: (json['nfc_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      nfcTagCount: json['nfc_tag_count'] ?? 0,
    );
  }

  /// ✅ เพิ่ม method นี้
  Map<String, dynamic> toMap() {
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'nfc_tags': nfcTags,
      'nfc_tag_count': nfcTagCount,
    };
  }

  /// ✅ เพิ่ม toJson alias
  Map<String, dynamic> toJson() => toMap();
}