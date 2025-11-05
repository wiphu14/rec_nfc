import 'dart:io';
import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../models/event_record_model.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isCreating = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastCreatedEvent;
  List<EventRecordModel> _events = [];

  // Getters
  bool get isCreating => _isCreating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastCreatedEvent => _lastCreatedEvent;
  List<EventRecordModel> get events => _events;

  // Create event with image
  Future<bool> createEventWithImage({
    required int sessionId,
    required int checkpointId,
    required int nfcTagId,
    String? eventNote,
    File? imageFile,
    double? latitude,
    double? longitude,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _eventService.createEventWithImage(
        sessionId: sessionId,
        checkpointId: checkpointId,
        nfcTagId: nfcTagId,
        eventNote: eventNote,
        imageFile: imageFile,
        latitude: latitude,
        longitude: longitude,
        deviceTime: DateTime.now().toIso8601String(),
      );

      if (result['success']) {
        _lastCreatedEvent = result;
        _errorMessage = null;
        
        _isCreating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        
        _isCreating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  // Create event without image
  Future<bool> createEvent({
    required int sessionId,
    required int checkpointId,
    required int nfcTagId,
    String? eventNote,
    String? imagePath,
    String? imageThumbnail,
    double? latitude,
    double? longitude,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _eventService.createEvent(
        sessionId: sessionId,
        checkpointId: checkpointId,
        nfcTagId: nfcTagId,
        eventNote: eventNote,
        imagePath: imagePath,
        imageThumbnail: imageThumbnail,
        latitude: latitude,
        longitude: longitude,
        deviceTime: DateTime.now().toIso8601String(),
      );

      if (result['success']) {
        _lastCreatedEvent = result;
        _errorMessage = null;
        
        _isCreating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        
        _isCreating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  // Clear last created event
  void clearLastCreatedEvent() {
    _lastCreatedEvent = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load event history
  Future<void> loadEventHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For now, we'll create some mock data since we don't have a dedicated history endpoint
      // In a real app, you would call your API to get historical events
      _events = [
        EventRecordModel(
          id: 1,
          checkpointName: 'จุดตรวจ A1',
          checkpointCode: 'A001',
          status: 'completed',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          note: 'ตรวจสอบเรียบร้อย',
        ),
        EventRecordModel(
          id: 2,
          checkpointName: 'จุดตรวจ B2',
          checkpointCode: 'B002',
          status: 'completed',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          note: 'พบความผิดปกติเล็กน้อย',
        ),
        EventRecordModel(
          id: 3,
          checkpointName: 'จุดตรวจ C3',
          checkpointCode: 'C003',
          status: 'pending',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          note: null,
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาดในการโหลดประวัติ: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}