import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../models/checkpoint_model.dart';
import '../../models/session_model.dart';
import '../../providers/nfc_provider.dart';
import '../../widgets/loading_widget.dart';

class CheckpointScanScreen extends StatefulWidget {
  final CheckpointModel checkpoint;
  final SessionModel session;

  const CheckpointScanScreen({
    super.key,
    required this.checkpoint,
    required this.session,
  });

  @override
  State<CheckpointScanScreen> createState() => _CheckpointScanScreenState();
}

class _CheckpointScanScreenState extends State<CheckpointScanScreen> {
  @override
  void initState() {
    super.initState();
    _checkNfcAndStartScan();
  }

  Future<void> _checkNfcAndStartScan() async {
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);

    final available = await nfcProvider.checkNfcAvailability();

    if (!available) {
      if (mounted) {
        _showErrorDialog(
          'NFC ไม่พร้อมใช้งาน',
          'กรุณาเปิด NFC ในการตั้งค่าของอุปกรณ์',
        );
      }
      return;
    }

    _startScanning();
  }

  Future<void> _startScanning() async {
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);

    final result = await nfcProvider.startScan();

    if (result != null && mounted) {
      // Navigate to next screen
      _navigateToNextScreen(result);
    }
  }

  void _navigateToNextScreen(dynamic scanResult) {
    if (widget.checkpoint.requirePhoto) {
      // Go to camera screen
      Navigator.pushReplacementNamed(
        context,
        '/camera_capture',
        arguments: {
          'checkpoint': widget.checkpoint,
          'session': widget.session,
          'scan_result': scanResult,
        },
      );
    } else {
      // Go directly to event note screen
      Navigator.pushReplacementNamed(
        context,
        '/event_note',
        arguments: {
          'checkpoint': widget.checkpoint,
          'session': widget.session,
          'scan_result': scanResult,
          'image_path': null,
        },
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppConfig.errorColor),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkNfcAndStartScan();
            },
            child: const Text('ลองอีกครั้ง'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);
    nfcProvider.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          final nfcProvider = Provider.of<NfcProvider>(context, listen: false);
          await nfcProvider.stopScan();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('สแกน NFC Tag'),
          backgroundColor: AppConfig.primaryColor,
        ),
        body: Consumer<NfcProvider>(
          builder: (context, nfcProvider, child) {
            if (nfcProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppConfig.errorColor,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        nfcProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkNfcAndStartScan,
                      child: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppConfig.primaryColor.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // NFC Icon Animation
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConfig.primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.nfc,
                          size: 80,
                          color: nfcProvider.isScanning
                              ? AppConfig.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Checkpoint Info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.checkpoint.checkpointName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.checkpoint.checkpointCode,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Status Message
                    if (nfcProvider.isScanning)
                      Column(
                        children: [
                          const LoadingWidget(),
                          const SizedBox(height: 16),
                          Text(
                            nfcProvider.statusMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppConfig.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      const Text(
                        'กรุณานำอุปกรณ์เข้าใกล้ NFC Tag',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 