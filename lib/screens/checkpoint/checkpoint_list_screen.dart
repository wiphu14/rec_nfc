import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkpoint_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import 'checkpoint_detail_screen.dart';

class CheckpointListScreen extends StatefulWidget {
  const CheckpointListScreen({super.key});

  @override
  State<CheckpointListScreen> createState() => _CheckpointListScreenState();
}

class _CheckpointListScreenState extends State<CheckpointListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadData();
    });
  }

  Future<void> _checkAuthAndLoadData() async {
    print('╔════════════════════════════════════════╗');
    print('║   CHECKPOINT LIST SCREEN - INIT        ║');
    print('╚════════════════════════════════════════╝');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('🔐 Checking auth status...');
    print('   - isLoggedIn: ${authProvider.isLoggedIn}');
    print('   - user: ${authProvider.user?.username}');
    print('   - token exists: ${authProvider.token != null}');

    if (!authProvider.isLoggedIn || authProvider.token == null) {
      print('❌ Not logged in - redirecting to login');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    print('✅ User is logged in - loading data');
    await _loadData();
  }

  Future<void> _loadData() async {
    print('📍 Loading checkpoints and session...');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checkpointProvider = Provider.of<CheckpointProvider>(
      context,
      listen: false,
    );
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );

    // ✅ ส่ง token เป็น parameter
    await checkpointProvider.loadCheckpoints(authProvider.token!);

    // ✅ ไม่ต้องรับค่า return เพราะเป็น Future<void>
    await sessionProvider.loadActiveSession();

    // ✅ ตรวจสอบ error จาก errorMessage แทน tokenExpired
    if (mounted && checkpointProvider.errorMessage != null) {
      // ถ้ามี error message ที่บอกว่า token หมดอายุ
      if (checkpointProvider.errorMessage!.contains('Token') ||
          checkpointProvider.errorMessage!.contains('token')) {
        print('! Token expired - logging out');
        await authProvider.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }

    print('✅ Data loading completed');
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการจุดตรวจ'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<CheckpointProvider>(
          builder: (context, checkpointProvider, child) {
            // แสดง loading
            if (checkpointProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // แสดง error
            if (checkpointProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      checkpointProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              );
            }

            // ไม่มีจุดตรวจ
            if (checkpointProvider.checkpoints.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ไม่มีจุดตรวจ',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('รีเฟรช'),
                    ),
                  ],
                ),
              );
            }

            // แสดงรายการจุดตรวจ
            return Column(
              children: [
                // สถิติ
                if (checkpointProvider.statistics != null)
                  _buildStatistics(checkpointProvider.statistics!),

                // รายการจุดตรวจ
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: checkpointProvider.checkpoints.length,
                    itemBuilder: (context, index) {
                      final checkpoint = checkpointProvider.checkpoints[index];
                      return _buildCheckpointCard(checkpoint);
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

  Widget _buildStatistics(Map<String, dynamic> statistics) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'ทั้งหมด',
            statistics['total']?.toString() ?? '0',
            Colors.blue,
          ),
          _buildStatItem(
            'บังคับ',
            statistics['required']?.toString() ?? '0',
            Colors.orange,
          ),
          _buildStatItem(
            'ไม่บังคับ',
            statistics['optional']?.toString() ?? '0',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCheckpointCard(checkpoint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: checkpoint.isRequired ? Colors.orange : Colors.green,
          child: Text(
            checkpoint.sequenceOrder.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          checkpoint.checkpointName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(checkpoint.checkpointCode),
            if (checkpoint.locationDetail != null)
              Text(
                checkpoint.locationDetail!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checkpoint.requirePhoto)
              const Icon(Icons.camera_alt, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            if (checkpoint.nfcTagCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${checkpoint.nfcTagCount} NFC',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),

        onTap: () async {
          // ✅ ไปหน้าตรวจจุดโดยตรง
          final result = await Navigator.pushNamed(
            context,
            '/checkpoint-inspect',
            arguments: checkpoint.toMap(),
          );

          if (result == true && mounted) {
            _refreshData();
          }
        },
      ),
    );
  }
}
