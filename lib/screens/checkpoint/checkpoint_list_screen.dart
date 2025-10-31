import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/checkpoint_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/checkpoint_card.dart';
import '../../widgets/loading_widget.dart';

class CheckpointListScreen extends StatefulWidget {
  const CheckpointListScreen({super.key});

  @override
  State<CheckpointListScreen> createState() => _CheckpointListScreenState();
}

class _CheckpointListScreenState extends State<CheckpointListScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final checkpointProvider =
        Provider.of<CheckpointProvider>(context, listen: false);
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    await checkpointProvider.loadCheckpoints();
    await sessionProvider.loadActiveSession();
  }

  Future<void> _startNewSession() async {
    if (!mounted) return;

    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เริ่มรอบการตรวจใหม่'),
        content: const Text('คุณต้องการเริ่มรอบการตรวจใหม่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
            ),
            child: const Text('เริ่มรอบการตรวจ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await sessionProvider.createSession();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เริ่มรอบการตรวจใหม่สำเร็จ'),
            backgroundColor: AppConfig.successColor,
          ),
        );
        setState(() {});
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                sessionProvider.errorMessage ?? 'ไม่สามารถเริ่มรอบการตรวจได้'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    }
  }

  void _navigateToCheckpointScan(int checkpointId) {
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    final checkpointProvider =
        Provider.of<CheckpointProvider>(context, listen: false);

    if (sessionProvider.currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเริ่มรอบการตรวจก่อน'),
          backgroundColor: AppConfig.warningColor,
        ),
      );
      return;
    }

    final checkpoint = checkpointProvider.checkpoints
        .firstWhere((cp) => cp.id == checkpointId);

    Navigator.pushNamed(
      context,
      '/checkpoint_scan',
      arguments: {
        'checkpoint': checkpoint,
        'session': sessionProvider.currentSession!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการจุดตรวจ'),
        backgroundColor: AppConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer2<CheckpointProvider, SessionProvider>(
          builder: (context, checkpointProvider, sessionProvider, child) {
            if (checkpointProvider.isLoading || sessionProvider.isLoading) {
              return const Center(child: LoadingWidget());
            }

            if (checkpointProvider.checkpoints.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ไม่มีจุดตรวจ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final activeSession = sessionProvider.currentSession;

            return Column(
              children: [
                // Session Status Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: activeSession != null
                        ? AppConfig.successColor.withValues(alpha: 0.1)
                        : AppConfig.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activeSession != null
                          ? AppConfig.successColor
                          : AppConfig.warningColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            activeSession != null
                                ? Icons.play_circle_fill
                                : Icons.warning_amber_rounded,
                            color: activeSession != null
                                ? AppConfig.successColor
                                : AppConfig.warningColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activeSession != null
                                  ? 'รอบการตรวจกำลังดำเนินการ'
                                  : 'ยังไม่ได้เริ่มรอบการตรวจ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (activeSession == null)
                            ElevatedButton(
                              onPressed: _startNewSession,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConfig.primaryColor,
                              ),
                              child: const Text('เริ่มรอบการตรวจ'),
                            ),
                        ],
                      ),
                      if (activeSession != null) ...[
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ความคืบหน้า:'),
                            Text(
                              '${activeSession.completedCheckpoints}/${activeSession.totalCheckpoints}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: activeSession.totalCheckpoints > 0
                              ? activeSession.completedCheckpoints /
                                  activeSession.totalCheckpoints
                              : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppConfig.successColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Checkpoint List
                Expanded(
                  child: ListView.builder(
                    itemCount: checkpointProvider.checkpoints.length,
                    itemBuilder: (context, index) {
                      final checkpoint = checkpointProvider.checkpoints[index];
                      final isCompleted = sessionProvider
                          .isCheckpointCompleted(checkpoint.id);

                      return CheckpointCard(
                        checkpoint: checkpoint,
                        isCompleted: isCompleted,
                        onTap: () {
                          _navigateToCheckpointScan(checkpoint.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}