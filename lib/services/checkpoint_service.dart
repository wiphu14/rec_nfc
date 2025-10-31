import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/checkpoint_model.dart';
import 'storage_service.dart';

class CheckpointService {
  final StorageService _storageService = StorageService();

  // Get all checkpoints
  Future<Map<String, dynamic>> getCheckpoints() async {
    try {
      final token = await _storageService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'ไม่พบ Token',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/checkpoints/get_checkpoints.php'),
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

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

        return {
          'success': true,
          'message': data['message'],
          'checkpoints': checkpoints,
          'statistics': statistics,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'ดึงข้อมูลไม่สำเร็จ',
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