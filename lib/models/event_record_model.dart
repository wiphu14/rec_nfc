class EventRecordModel {
  final int id;
  final String checkpointName;
  final String checkpointCode;
  final String status;
  final DateTime timestamp;
  final String? note;
  final String? imagePath;
  final String? imageThumbnail;
  final double? latitude;
  final double? longitude;

  EventRecordModel({
    required this.id,
    required this.checkpointName,
    required this.checkpointCode,
    required this.status,
    required this.timestamp,
    this.note,
    this.imagePath,
    this.imageThumbnail,
    this.latitude,
    this.longitude,
  });

  factory EventRecordModel.fromJson(Map<String, dynamic> json) {
    return EventRecordModel(
      id: json['id'] as int,
      checkpointName: json['checkpointName'] as String,
      checkpointCode: json['checkpointCode'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      imagePath: json['imagePath'] as String?,
      imageThumbnail: json['imageThumbnail'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkpointName': checkpointName,
      'checkpointCode': checkpointCode,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'imagePath': imagePath,
      'imageThumbnail': imageThumbnail,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}