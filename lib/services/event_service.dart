// lib/services/event_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class EventService {
  final StorageService _storageService = StorageService();

  /// Create event record with image upload
  Future<Map<String, dynamic>> createEventWithImage({
    required int sessionId,
    required int checkpointId,
    required int nfcTagId,
    String? eventNote,
    File? imageFile,
    double? latitude,
    double? longitude,
    String? deviceTime,
  }) async {
    try {
      final token = await _storageService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'ไม่พบ Token',
        };
      }

      // If have image, upload first
      String? imagePath;
      String? imageThumbnail;

      if (imageFile != null) {
        var uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.uploadImageEndpoint), // ✅ ใช้ ApiConfig
        );

        uploadRequest.headers['Authorization'] = 'Bearer $token';
        uploadRequest.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final uploadStreamedResponse = await uploadRequest.send();
        final uploadResponse = await http.Response.fromStream(uploadStreamedResponse);
        
        if (uploadResponse.statusCode != 200) {
          return {
            'success': false,
            'message': 'อัพโหลดรูปภาพไม่สำเร็จ (HTTP ${uploadResponse.statusCode})',
          };
        }

        final uploadData = jsonDecode(uploadResponse.body);

        if (uploadData['success'] != true) {
          return {
            'success': false,
            'message': 'อัพโหลดรูปภาพไม่สำเร็จ: ${uploadData['message']}',
          };
        }

        imagePath = uploadData['data']['image_path'];
        imageThumbnail = uploadData['data']['image_thumbnail'];
      }

      // Create event record
      final response = await http.post(
        Uri.parse(ApiConfig.createEventEndpoint), // ✅ ใช้ ApiConfig
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'session_id': sessionId,
          'checkpoint_id': checkpointId,
          'nfc_tag_id': nfcTagId,
          'event_note': eventNote,
          'image_path': imagePath,
          'image_thumbnail': imageThumbnail,
          'latitude': latitude,
          'longitude': longitude,
          'device_time': deviceTime ?? DateTime.now().toIso8601String(),
        }),
      ).timeout(ApiConfig.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'event_id': data['data']['event_id'],
          'scan_time': data['data']['scan_time'],
          'completed_checkpoints': data['data']['completed_checkpoints'],
          'total_checkpoints': data['data']['total_checkpoints'],
          'is_all_completed': data['data']['is_all_completed'],
          'progress_percentage': data['data']['progress_percentage'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'บันทึกเหตุการณ์ไม่สำเร็จ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }

  /// Create event record (without image upload - for backward compatibility)
  Future<Map<String, dynamic>> createEvent({
    required int sessionId,
    required int checkpointId,
    required int nfcTagId,
    String? eventNote,
    String? imagePath,
    String? imageThumbnail,
    double? latitude,
    double? longitude,
    String? deviceTime,
  }) async {
    try {
      final token = await _storageService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'ไม่พบ Token',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.createEventEndpoint),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'session_id': sessionId,
          'checkpoint_id': checkpointId,
          'nfc_tag_id': nfcTagId,
          'event_note': eventNote,
          'image_path': imagePath,
          'image_thumbnail': imageThumbnail,
          'latitude': latitude,
          'longitude': longitude,
          'device_time': deviceTime ?? DateTime.now().toIso8601String(),
        }),
      ).timeout(ApiConfig.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'event_id': data['data']['event_id'],
          'scan_time': data['data']['scan_time'],
          'completed_checkpoints': data['data']['completed_checkpoints'],
          'total_checkpoints': data['data']['total_checkpoints'],
          'is_all_completed': data['data']['is_all_completed'],
          'progress_percentage': data['data']['progress_percentage'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'บันทึกเหตุการณ์ไม่สำเร็จ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }
}