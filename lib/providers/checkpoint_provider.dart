import 'package:flutter/material.dart';
import '../models/checkpoint_model.dart';
import '../services/checkpoint_service.dart';
import 'package:flutter/foundation.dart';  // ← เพิ่มบรรทัดนี้

class CheckpointProvider with ChangeNotifier {
  final CheckpointService _checkpointService = CheckpointService();

  List<CheckpointModel> _checkpoints = [];
  CheckpointStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CheckpointModel> get checkpoints => _checkpoints;
  CheckpointStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get required checkpoints
  List<CheckpointModel> get requiredCheckpoints =>
      _checkpoints.where((c) => c.isRequired).toList();

  // Get optional checkpoints
  List<CheckpointModel> get optionalCheckpoints =>
      _checkpoints.where((c) => !c.isRequired).toList();

  // Load checkpoints
  Future<bool> loadCheckpoints() async {
    if (kDebugMode) {
      debugPrint('╔════════════════════════════════════════╗');
      debugPrint('║   CHECKPOINT PROVIDER - LOADING        ║');
      debugPrint('╚════════════════════════════════════════╝');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _checkpointService.getCheckpoints();

      if (kDebugMode) {
        debugPrint('📦 Service result:');
        debugPrint('   - Success: ${result['success']}');
        debugPrint('   - Message: ${result['message']}');
        debugPrint('   - Has checkpoints: ${result['checkpoints'] != null}');
        if (result['checkpoints'] != null) {
          debugPrint('   - Checkpoints count: ${result['checkpoints'].length}');
        }
      }

      if (result['success']) {
        _checkpoints = result['checkpoints'] ?? [];
        _statistics = result['statistics'];
        _errorMessage = null;

        if (kDebugMode) {
          debugPrint('✅ Successfully loaded ${_checkpoints.length} checkpoints');
          debugPrint('📊 Statistics:');
          debugPrint('   - Total: ${_statistics?.total ?? 0}');
          debugPrint('   - Required: ${_statistics?.required ?? 0}');
          debugPrint('   - Optional: ${_statistics?.optional ?? 0}');
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];

        if (kDebugMode) {
          debugPrint('❌ Failed to load checkpoints: $_errorMessage');
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';

      if (kDebugMode) {
        debugPrint('❌ Exception in loadCheckpoints: $e');
        debugPrint('📍 StackTrace: $stackTrace');
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get checkpoint by ID
  CheckpointModel? getCheckpointById(int id) {
    try {
      return _checkpoints.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if checkpoint is completed in session
  bool isCheckpointCompleted(int checkpointId, List<int> completedIds) {
    return completedIds.contains(checkpointId);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}