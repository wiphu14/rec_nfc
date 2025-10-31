class NfcScanResult {
  final String uid;
  final String type;
  final bool valid;
  final String scanTime;

  NfcScanResult({
    required this.uid,
    required this.type,
    required this.valid,
    required this.scanTime,
  });

  factory NfcScanResult.fromJson(Map<String, dynamic> json) {
    return NfcScanResult(
      uid: json['uid'] ?? '',
      type: json['type'] ?? 'Unknown',
      valid: json['valid'] ?? false,
      scanTime: json['scan_time'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'type': type,
      'valid': valid,
      'scan_time': scanTime,
    };
  }
}