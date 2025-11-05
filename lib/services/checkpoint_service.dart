import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/checkpoint_model.dart';
import 'storage_service.dart';

class CheckpointService {
  final StorageService _storageService = StorageService();

  // Get all checkpoints
  Future<Map<String, dynamic>> getCheckpoints() async {
    try {
      if (kDebugMode) {
        debugPrint('╔════════════════════════════════════════╗');
        debugPrint('║     FETCHING CHECKPOINTS               ║');
        debugPrint('╚════════════════════════════════════════╝');
      }

      final token = await _storageService.getToken();

      if (kDebugMode) {
        debugPrint('🔐 Token check:');
        debugPrint('   - Token exists: ${token != null}');
        debugPrint('   - Token is empty: ${token?.isEmpty ?? true}');
        if (token != null && token.isNotEmpty) {
          debugPrint('   - Token length: ${token.length}');
          debugPrint('   - Token preview: ${token.substring(0, min(50, token.length))}...');
        }
      }

      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ No token found');
        }
        return {
          'success': false,
          'message': 'ไม่พบ Token กรุณาเข้าสู่ระบบอีกครั้ง',
        };
      }

      final url = '${ApiConfig.baseUrl}/checkpoints/list.php';

      if (kDebugMode) {
        debugPrint('📍 URL: $url');
        debugPrint('🔑 Token: ${token.substring(0, min(30, token.length))}...');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (kDebugMode) {
        debugPrint('📊 Status Code: ${response.statusCode}');
        debugPrint('📋 Headers: ${response.headers}');
        debugPrint('📄 Response: ${response.body.substring(0, min(500, response.body.length))}...');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        List<CheckpointModel> checkpoints = [];
        
        if (data['data']['checkpoints'] != null) {
          checkpoints = (data['data']['checkpoints'] as List)
              .map((e) => CheckpointModel.fromJson(e))
              .toList();
        }

        CheckpointStatistics? statistics;
        if (data['data']['statistics'] != null) {
          statistics = CheckpointStatistics.fromJson(data['data']['statistics']);
        }

        if (kDebugMode) {
          debugPrint('✅ Successfully loaded ${checkpoints.length} checkpoints');
          debugPrint('📊 Statistics:');
          debugPrint('   Total: ${statistics?.total ?? 0}');
          debugPrint('   Required: ${statistics?.required ?? 0}');
          debugPrint('   Optional: ${statistics?.optional ?? 0}');
        }

        return {
          'success': true,
          'message': data['message'],
          'checkpoints': checkpoints,
          'statistics': statistics,
        };
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('❌ Unauthorized - Token may be expired');
        }
        return {
          'success': false,
          'message': 'Token หมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง',
          'token_expired': true,
        };
      } else {
        if (kDebugMode) {
          debugPrint('❌ Failed with status: ${response.statusCode}');
        }
        return {
          'success': false,
          'message': data['message'] ?? 'ดึงข้อมูลไม่สำเร็จ',
        };
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Exception in getCheckpoints: $e');
        debugPrint('📍 StackTrace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }

  // Helper method
  int min(int a, int b) => a < b ? a : b;
}