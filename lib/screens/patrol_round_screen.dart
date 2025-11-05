// lib/screens/patrol_round_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkpoint_provider.dart';

class PatrolRoundScreen extends StatefulWidget {
  const PatrolRoundScreen({super.key});

  @override
  State<PatrolRoundScreen> createState() => _PatrolRoundScreenState();
}

class _PatrolRoundScreenState extends State<PatrolRoundScreen> {
  @override
  void initState() {
    super.initState();
    
    // TODO: เริ่มรอบการตรวจใหม่
  }

  @override
  Widget build(BuildContext context) {
    final checkpointProvider = Provider.of<CheckpointProvider>(context);
    final checkpoints = checkpointProvider.checkpoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รอบการตรวจ'),
        backgroundColor: Colors.green,
      ),
      body: checkpoints.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่พบจุดตรวจ'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: checkpoints.length,
              itemBuilder: (context, index) {
                final checkpoint = checkpoints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: checkpoint.isRequired
                          ? Colors.green
                          : Colors.orange,
                      child: Text('${checkpoint.sequenceOrder}'),
                    ),
                    title: Text(checkpoint.checkpointName),
                    subtitle: Text(checkpoint.checkpointCode),
                    trailing: const Icon(Icons.nfc),
                    onTap: () {
                      // TODO: สแกน NFC
                      _showScanDialog(checkpoint.checkpointName);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showScanDialog(String checkpointName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สแกน NFC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.nfc, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text('กรุณาแตะ NFC Tag ที่\n$checkpointName'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }
}