import 'package:flutter/foundation.dart';
import '../models/checkpoint_model.dart';
import '../services/checkpoint_service.dart';

class CheckpointProvider with ChangeNotifier {
  List<CheckpointModel> _checkpoints = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  List<CheckpointModel> get checkpoints => _checkpoints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;

  /// โหลดรายการจุดตรวจทั้งหมด
  Future<void> loadCheckpoints(String token) async {
    if (kDebugMode) {
      print('╔════════════════════════════════════════╗');
      print('║   CHECKPOINT PROVIDER - LOADING        ║');
      print('╚════════════════════════════════════════╝');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ เรียก static method ด้วย class name และส่ง token
      final result = await CheckpointService.getCheckpoints(token);

      if (kDebugMode) {
        print('📦 Service result:');
        print('   - Success: ${result['success']}');
        print('   - Message: ${result['message']}');
        print('   - Token expired: ${result['token_expired']}');
        print('   - Has checkpoints: ${result['checkpoints'] != null}');
      }

      if (result['success']) {
        // แปลง JSON เป็น CheckpointModel
        final List<dynamic> checkpointsJson = result['checkpoints'] ?? [];
        _checkpoints = checkpointsJson
            .map((json) => CheckpointModel.fromJson(json))
            .toList();
        
        _statistics = result['statistics'];
        _errorMessage = null;

        if (kDebugMode) {
          print('✅ Loaded ${_checkpoints.length} checkpoints');
        }
      } else {
        _errorMessage = result['message'] ?? 'ไม่สามารถโหลดข้อมูลได้';
        _checkpoints = [];
        _statistics = null;

        if (kDebugMode) {
          print('❌ Failed to load checkpoints: $_errorMessage');
        }
      }

    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: $e';
      _checkpoints = [];
      _statistics = null;

      if (kDebugMode) {
        print('❌ Exception in loadCheckpoints: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// รีเซ็ตข้อมูล
  void reset() {
    _checkpoints = [];
    _statistics = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// ค้นหาจุดตรวจตาม ID
  CheckpointModel? findCheckpointById(int id) {
    try {
      return _checkpoints.firstWhere((checkpoint) => checkpoint.id == id);
    } catch (e) {
      return null;
    }
  }

  /// กรองจุดตรวจที่บังคับ
  List<CheckpointModel> get requiredCheckpoints {
    return _checkpoints.where((c) => c.isRequired).toList();
  }

  /// กรองจุดตรวจที่ไม่บังคับ
  List<CheckpointModel> get optionalCheckpoints {
    return _checkpoints.where((c) => !c.isRequired).toList();
  }

  /// จำนวนจุดตรวจทั้งหมด
  int get totalCheckpoints => _checkpoints.length;

  /// จำนวนจุดตรวจที่บังคับ
  int get requiredCount => _statistics?['required'] ?? 0;

  /// จำนวนจุดตรวจที่ไม่บังคับ
  int get optionalCount => _statistics?['optional'] ?? 0;
}