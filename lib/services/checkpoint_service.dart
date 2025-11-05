import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class CheckpointService {
  // ✅ ใช้ static final แทน const (ถ้า baseUrl ไม่ใช่ compile-time constant)
  static final String baseUrl = AppConfig.baseUrl;

  /// ดึงรายการจุดตรวจทั้งหมด
  static Future<Map<String, dynamic>> getCheckpoints(String token) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║     FETCHING CHECKPOINTS               ║');
        print('╚════════════════════════════════════════╝');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints/list.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'checkpoints': data['data']?['checkpoints'] ?? [],
          'statistics': data['data']?['statistics'] ?? {},
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token หมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง',
          'token_expired': true,
        };
      } else {
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาด (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in getCheckpoints: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// ตรวจสอบ NFC UID
  static Future<Map<String, dynamic>> verifyNfc(
    String token,
    String nfcUid,
  ) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║        VERIFYING NFC TAG               ║');
        print('╚════════════════════════════════════════╝');
        print('🔑 NFC UID: $nfcUid');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/checkpoints/verify_nfc.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nfc_uid': nfcUid,
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'checkpoint': data['data']?['checkpoint'],
          'nfc_tag_id': data['data']?['nfc_tag_id'],
        };
      } else {
        return {
          'success': false,
          'message': 'ไม่สามารถตรวจสอบ NFC ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in verifyNfc: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// บันทึกการตรวจจุด (พร้อมรูปภาพ)
  static Future<Map<String, dynamic>> logCheckpoint({
    required String token,
    required int sessionId,
    required int checkpointId,
    String? nfcUid,
    String? notes,
    File? photo,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║      LOGGING CHECKPOINT                ║');
        print('╚════════════════════════════════════════╝');
        print('📍 Session ID: $sessionId');
        print('📍 Checkpoint ID: $checkpointId');
        print('🔑 NFC UID: $nfcUid');
        print('📸 Has Photo: ${photo != null}');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/checkpoints/log_checkpoint.php'),
      );

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Form fields
      request.fields['session_id'] = sessionId.toString();
      request.fields['checkpoint_id'] = checkpointId.toString();
      
      if (nfcUid != null) {
        request.fields['nfc_uid'] = nfcUid;
      }
      
      if (notes != null && notes.isNotEmpty) {
        request.fields['notes'] = notes;
      }
      
      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      // Add photo if available
      if (photo != null) {
        var photoFile = await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(photoFile);
      }

      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'log_id': data['data']?['log_id'],
          'checkpoint_name': data['data']?['checkpoint_name'],
          'progress': data['data']?['progress'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถบันทึกได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in logCheckpoint: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }
}