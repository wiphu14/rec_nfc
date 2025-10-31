import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'dart:math' as math;

class NfcScanWidget extends StatefulWidget {
  final bool isScanning;
  final String? statusText;
  final VoidCallback? onTap;

  const NfcScanWidget({
    Key? key,
    this.isScanning = false,
    this.statusText,
    this.onTap,
  }) : super(key: key);

  @override
  State<NfcScanWidget> createState() => _NfcScanWidgetState();
}

class _NfcScanWidgetState extends State<NfcScanWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isScanning) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(NfcScanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  void _startAnimation() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _stopAnimation() {
    _pulseController.stop();
    _rotationController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 280,
        padding: const EdgeInsets.all(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse rings
            if (widget.isScanning)
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * (index + 1) * 0.3);
                    final opacity = 1.0 - _pulseController.value;

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppConfig.primaryColor.withOpacity(opacity * 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

            // NFC icon
            AnimatedBuilder(
              animation: widget.isScanning ? _rotationController : const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Transform.rotate(
                  angle: widget.isScanning ? _rotationController.value * 2 * math.pi : 0,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.isScanning
                      ? AppConfig.primaryColor
                      : Colors.grey[400],
                  shape: BoxShape.circle,
                  boxShadow: widget.isScanning
                      ? [
                          BoxShadow(
                            color: AppConfig.primaryColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: const Icon(
                  Icons.nfc,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            // Status text
            if (widget.statusText != null)
              Positioned(
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.isScanning
                        ? AppConfig.primaryColor.withOpacity(0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isScanning
                          ? AppConfig.primaryColor
                          : Colors.grey[400]!,
                    ),
                  ),
                  child: Text(
                    widget.statusText!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.isScanning
                          ? AppConfig.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}