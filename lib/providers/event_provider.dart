import 'dart:io';
import 'package:flutter/material.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isCreating = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastCreatedEvent;

  // Getters
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastCreatedEvent => _lastCreatedEvent;

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
}