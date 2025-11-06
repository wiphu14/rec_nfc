import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class NfcAdminService {
  static final String baseUrl = AppConfig.baseUrl;

  /// ดึงรายการ NFC Tags ทั้งหมด
  static Future<Map<String, dynamic>> getNfcTags(String token) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║     FETCHING NFC TAGS (ADMIN)          ║');
        print('╚════════════════════════════════════════╝');
      }

      // ✅ ใช้ endpoint ที่ถูกต้อง
      final response = await http.get(
        Uri.parse('$baseUrl/nfc/list_nfc_tags.php'),
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
          'tags': data['data']?['tags'] ?? [],
          'statistics': data['data']?['statistics'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': 'ไม่สามารถดึงข้อมูล NFC Tags ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in getNfcTags: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// เพิ่ม NFC Tag ใหม่
  static Future<Map<String, dynamic>> addNfcTag(
    String token,
    String nfcUid, {
    int? checkpointId,
    String? description,
  }) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║        ADDING NFC TAG                  ║');
        print('╚════════════════════════════════════════╝');
        print('🔑 NFC UID: $nfcUid');
        print('📍 Checkpoint ID: $checkpointId');
      }

      // ✅ ใช้ endpoint ที่ถูกต้อง
      final response = await http.post(
        Uri.parse('$baseUrl/nfc/register_nfc_tag.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nfc_uid': nfcUid,
          if (checkpointId != null) 'checkpoint_id': checkpointId,
          if (description != null && description.isNotEmpty)
            'description': description,
          'status': 'active', // ✅ เพิ่ม status
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'tag': data['data'], // ✅ backend return data ไม่มี nested 'tag'
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถเพิ่ม NFC Tag ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in addNfcTag: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// แก้ไข NFC Tag
  static Future<Map<String, dynamic>> updateNfcTag(
    String token,
    int tagId, {
    int? checkpointId,
    String? nfcUid,
    String? status,
  }) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║       UPDATING NFC TAG                 ║');
        print('╚════════════════════════════════════════╝');
        print('🆔 Tag ID: $tagId');
      }

      // ✅ ใช้ endpoint ที่ถูกต้อง
      final response = await http.put(
        Uri.parse('$baseUrl/nfc/update_nfc_tag.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tag_id': tagId,
          if (checkpointId != null) 'checkpoint_id': checkpointId,
          if (nfcUid != null) 'nfc_uid': nfcUid,
          if (status != null) 'status': status,
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
          'tag': data['data'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถแก้ไข NFC Tag ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in updateNfcTag: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// เปิด/ปิดใช้งาน NFC Tag (Toggle status)
  static Future<Map<String, dynamic>> toggleNfcTag(
    String token,
    int tagId,
  ) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║       TOGGLING NFC TAG                 ║');
        print('╚════════════════════════════════════════╝');
        print('🆔 Tag ID: $tagId');
      }

      // ✅ เนื่องจาก backend ไม่มี toggle endpoint แยก
      // เราต้องดึงข้อมูลมาก่อน แล้วเปลี่ยน status
      
      // 1. ดึงข้อมูล tag ปัจจุบัน
      final listResult = await getNfcTags(token);
      if (!listResult['success']) {
        return listResult;
      }

      // หา tag ที่ต้องการ
      final tags = listResult['tags'] as List;
      final tag = tags.firstWhere(
        (t) => t['id'] == tagId,
        orElse: () => null,
      );

      if (tag == null) {
        return {
          'success': false,
          'message': 'ไม่พบ NFC Tag นี้',
        };
      }

      // 2. สลับ status
      final currentStatus = tag['status'] ?? 'active';
      final newStatus = currentStatus == 'active' ? 'inactive' : 'active';

      // 3. Update status
      return await updateNfcTag(
        token,
        tagId,
        status: newStatus,
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in toggleNfcTag: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// ลบ NFC Tag
  static Future<Map<String, dynamic>> deleteNfcTag(
    String token,
    int tagId,
  ) async {
    try {
      if (kDebugMode) {
        print('╔════════════════════════════════════════╗');
        print('║       DELETING NFC TAG                 ║');
        print('╚════════════════════════════════════════╝');
        print('🆔 Tag ID: $tagId');
      }

      // ✅ ใช้ endpoint ที่ถูกต้อง
      final response = await http.delete(
        Uri.parse('$baseUrl/nfc/delete_nfc_tag.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tag_id': tagId,
          'soft_delete': true, // ✅ ใช้ soft delete (เปลี่ยนเป็น inactive)
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
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถลบ NFC Tag ได้',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in deleteNfcTag: $e');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }
}