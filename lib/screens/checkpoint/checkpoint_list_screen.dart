import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
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
  bool _isInitialized = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    debugPrint('╔════════════════════════════════════════╗');
    debugPrint('║   CHECKPOINT LIST SCREEN - INIT        ║');
    debugPrint('╚════════════════════════════════════════╝');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized && !_isLoadingData) {
      _isInitialized = true;
      
      // Run after frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuthAndLoadData();
      });
    }
  }

  Future<void> _checkAuthAndLoadData() async {
    if (!mounted) return;

    // ป้องกันการโหลดซ้ำ
    if (_isLoadingData) {
      debugPrint('⚠️ Already loading data, skipping...');
      return;
    }

    setState(() {
      _isLoadingData = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      debugPrint('🔐 Checking auth status...');
      debugPrint('   - isLoggedIn: ${authProvider.isLoggedIn}');
      debugPrint('   - user: ${authProvider.user?.username ?? "null"}');
      debugPrint('   - token exists: ${authProvider.token != null}');

      // Check if user is still logged in
      if (!authProvider.isLoggedIn) {
        debugPrint('⚠️ User not logged in - redirecting to login');
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      debugPrint('✅ User is logged in - loading data');
      await _loadData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    debugPrint('📍 Loading checkpoints and session...');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checkpointProvider =
        Provider.of<CheckpointProvider>(context, listen: false);
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    // Load checkpoints
    final checkpointSuccess = await checkpointProvider.loadCheckpoints();
    
    if (!checkpointSuccess && mounted) {
      // Check if token expired
      if (checkpointProvider.tokenExpired) {
        debugPrint('⚠️ Token expired - logging out');
        
        await authProvider.logout();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เซสชันหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง'),
              backgroundColor: AppConfig.errorColor,
              duration: Duration(seconds: 3),
            ),
          );
          
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // แสดง error แต่ไม่ redirect
      if (mounted && checkpointProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkpointProvider.errorMessage!),
            backgroundColor: AppConfig.errorColor,
            action: SnackBarAction(
              label: 'ลองอีกครั้ง',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }

    // Load session (don't redirect on failure)
    await sessionProvider.loadActiveSession();

    if (mounted) {
      debugPrint('✅ Data loading completed');
    }
  }

  Future<void> _startNewSession() async {
    if (!mounted) return;

    debugPrint('╔════════════════════════════════════════╗');
    debugPrint('║      START NEW SESSION REQUEST         ║');
    debugPrint('╚════════════════════════════════════════╝');

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
            onPressed: () {
              debugPrint('❌ User cancelled session creation');
              Navigator.pop(dialogContext, false);
            },
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('✅ User confirmed session creation');
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
            ),
            child: const Text('เริ่มรอบการตรวจ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      debugPrint('🔄 Calling sessionProvider.createSession()...');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('กำลังสร้างรอบการตรวจ...'),
                ],
              ),
            ),
          ),
        ),
      );

      final success = await sessionProvider.createSession();

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        debugPrint('✅ Session created successfully!');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เริ่มรอบการตรวจใหม่สำเร็จ'),
            backgroundColor: AppConfig.successColor,
          ),
        );
        setState(() {});
      } else if (mounted) {
        final errorMsg = sessionProvider.errorMessage ?? 'ไม่สามารถเริ่มรอบการตรวจได้';
        
        debugPrint('❌ Failed to create session: $errorMsg');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppConfig.errorColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ลองอีกครั้ง',
              textColor: Colors.white,
              onPressed: _startNewSession,
            ),
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
        child: Consumer3<AuthProvider, CheckpointProvider, SessionProvider>(
          builder: (context, authProvider, checkpointProvider, sessionProvider, child) {
            // Show loading while initializing or loading data
            if (!_isInitialized || _isLoadingData) {
              return const Center(child: LoadingWidget());
            }

            // Check if still loading
            if (checkpointProvider.isLoading) {
              return const Center(child: LoadingWidget());
            }

            // Show error if any (without redirecting)
            if (checkpointProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        checkpointProvider.errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('ลองอีกครั้ง'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
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
                    const SizedBox(height: 8),
                    Text(
                      'กรุณาติดต่อผู้ดูแลระบบเพื่อเพิ่มจุดตรวจ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
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