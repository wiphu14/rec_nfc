import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    if (authProvider.token != null) {
      await sessionProvider.loadSessionHistory(authProvider.token!);
    }
  }

  Future<void> _refreshData() async {
    await _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติ Session'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<SessionProvider>(
          builder: (context, sessionProvider, child) {
            // แสดง loading
            if (sessionProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // แสดง error
            if (sessionProvider.errorMessage != null) {
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
                      sessionProvider.errorMessage!,
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

            // ไม่มี session
            if (sessionProvider.sessionHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ยังไม่มีประวัติ Session',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
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

            // แสดงรายการ session
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sessionProvider.sessionHistory.length,
              itemBuilder: (context, index) {
                final session = sessionProvider.sessionHistory[index];
                return _buildSessionCard(session);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final startTime = DateTime.tryParse(session['start_time'] ?? '');
    final endTime = DateTime.tryParse(session['end_time'] ?? '');
    final status = session['status'] ?? 'unknown';
    final progress = session['progress'] ?? {};

    Color statusColor = Colors.grey;
    String statusText = 'ไม่ทราบสถานะ';

    if (status == 'active') {
      statusColor = Colors.green;
      statusText = 'กำลังดำเนินการ';
    } else if (status == 'completed') {
      statusColor = Colors.blue;
      statusText = 'เสร็จสิ้น';
    } else if (status == 'cancelled') {
      statusColor = Colors.red;
      statusText = 'ยกเลิก';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            '${session['id'] ?? '?'}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          'Session #${session['id']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (startTime != null)
              Text('เริ่ม: ${dateFormat.format(startTime)}'),
            Text(
              statusText,
              style: TextStyle(color: statusColor),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ข้อมูล session
                _buildInfoRow('ID', session['id']?.toString() ?? 'N/A'),
                _buildInfoRow('สถานะ', statusText),
                if (startTime != null)
                  _buildInfoRow('เวลาเริ่ม', dateFormat.format(startTime)),
                if (endTime != null)
                  _buildInfoRow('เวลาสิ้นสุด', dateFormat.format(endTime)),

                const Divider(height: 20),

                // ความคืบหน้า
                const Text(
                  'ความคืบหน้า',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'ตรวจแล้ว',
                  '${progress['completed'] ?? 0}/${progress['total'] ?? 0}',
                ),
                if (progress['percentage'] != null)
                  LinearProgressIndicator(
                    value: (progress['percentage'] as num).toDouble() / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}