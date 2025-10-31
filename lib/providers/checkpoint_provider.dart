import 'package:flutter/material.dart';
import '../models/checkpoint_model.dart';
import '../services/checkpoint_service.dart';

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _checkpointService.getCheckpoints();

      if (result['success']) {
        _checkpoints = result['checkpoints'] ?? [];
        _statistics = result['statistics'];
        _errorMessage = null;
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      
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