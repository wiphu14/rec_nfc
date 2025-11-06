import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/checkpoint_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
    _debugUserRole();
  }

  // ✅ เพิ่มฟังก์ชัน debug เพื่อเช็ค role
  void _debugUserRole() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      print('╔════════════════════════════════════════╗');
      print('║         DEBUG USER ROLE                ║');
      print('╚════════════════════════════════════════╝');
      print('👤 Username: ${user?.username}');
      print('🎭 Role: ${user?.role}');
      print('👑 Is Admin: ${authProvider.isAdmin}');
      print('📧 Email: ${user?.email}');
      print('═══════════════════════════════════════════');
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final checkpointProvider = Provider.of<CheckpointProvider>(context, listen: false);

    if (authProvider.token != null) {
      await Future.wait([
        sessionProvider.loadActiveSession(),
        checkpointProvider.loadCheckpoints(authProvider.token!),
      ]);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await _showLogoutConfirmDialog();
              if (confirm == true && mounted) {
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              _buildUserInfoCard(user),

              const SizedBox(height: 16),

              // Active Session Card
              _buildActiveSessionCard(),

              const SizedBox(height: 16),

              // Quick Actions
              _buildQuickActionsCard(),

              const SizedBox(height: 16),

              // Statistics
              _buildStatisticsCard(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlue],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สวัสดี,',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.fullName ?? user?.username ?? 'ผู้ใช้งาน',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.role ?? 'N/A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionCard() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        final activeSession = sessionProvider.activeSession;
        final hasSession = activeSession != null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.play_circle, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Session ปัจจุบัน',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (hasSession)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'กำลังดำเนินการ',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(),

                if (!hasSession)
                  Column(
                    children: [
                      const Text(
                        'ยังไม่มี Session ที่ Active',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: sessionProvider.isLoading
                              ? null
                              : () => _createSession(),
                          icon: const Icon(Icons.add),
                          label: const Text('เริ่ม Session ใหม่'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  _buildActiveSessionContent(activeSession),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveSessionContent(Map<String, dynamic> activeSession) {
    final Map<String, dynamic>? progressData = 
        activeSession['progress'] as Map<String, dynamic>?;
    final int completed = progressData?['completed'] ?? 0;
    final int total = progressData?['total'] ?? 1;

    return Column(
      children: [
        _buildSessionInfoRow(
          'Session ID',
          '#${activeSession['id']?.toString() ?? 'N/A'}',
        ),
        
        if (progressData != null) ...[
          _buildSessionInfoRow(
            'ความคืบหน้า',
            '$completed/$total',
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completed / total.toDouble(),
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.blue,
            ),
          ),
        ],

        const SizedBox(height: 12),
        Consumer<SessionProvider>(
          builder: (context, sessionProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: sessionProvider.isLoading
                    ? null
                    : () => _completeSession(activeSession['id'] as int?),
                icon: const Icon(Icons.check_circle),
                label: const Text('จบ Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildQuickActionsCard() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // ✅ เช็คหลายวิธี เพื่อความแน่ใจ
    final isAdmin = authProvider.isAdmin || 
                    user?.role?.toLowerCase() == 'admin' ||
                    user?.isAdmin == true;

    // ✅ Debug log
    print('🔍 Quick Actions - Is Admin: $isAdmin');
    print('🔍 User Role: ${user?.role}');
    print('🔍 AuthProvider.isAdmin: ${authProvider.isAdmin}');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เมนูด่วน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            
            // ✅ ใช้ Column + Wrap แทน GridView เพื่อให้แสดงปุ่มได้ไม่จำกัด
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // ปุ่มเริ่มการตรวจ
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _buildQuickActionButton(
                    icon: Icons.play_circle,
                    label: 'เริ่มการตรวจ',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/start-session'),
                  ),
                ),
                
                // ปุ่มจุดตรวจ
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _buildQuickActionButton(
                    icon: Icons.location_on,
                    label: 'จุดตรวจ',
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/checkpoints'),
                  ),
                ),
                
                // ปุ่มประวัติ
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _buildQuickActionButton(
                    icon: Icons.history,
                    label: 'ประวัติ',
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/sessions'),
                  ),
                ),
                
                // ✅ ปุ่ม Admin - แสดงเสมอถ้าเป็น admin
                if (isAdmin)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 64) / 2,
                    child: _buildQuickActionButton(
                      icon: Icons.admin_panel_settings,
                      label: 'จัดการระบบ',
                      color: Colors.purple,
                      onTap: () {
                        print('🎯 Admin button tapped!');
                        Navigator.pushNamed(context, '/admin-menu');
                      },
                    ),
                  ),
              ],
            ),
            
            // ✅ Debug info card (แสดงเฉพาะใน development)
            if (isAdmin) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, 
                         size: 16, 
                         color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'คุณเข้าสู่ระบบในฐานะ Admin (${user?.role})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Consumer<CheckpointProvider>(
      builder: (context, checkpointProvider, child) {
        final stats = checkpointProvider.statistics;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สถิติจุดตรวจ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'ทั้งหมด',
                      stats?['total']?.toString() ?? '0',
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'บังคับ',
                      stats?['required']?.toString() ?? '0',
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'ไม่บังคับ',
                      stats?['optional']?.toString() ?? '0',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _createSession() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    final result = await sessionProvider.createSession(authProvider.token!);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ เริ่ม Session สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeSession(int? sessionId) async {
    if (sessionId == null) return;

    final confirm = await _showCompleteSessionDialog();
    if (confirm != true || !mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    final result = await sessionProvider.completeSession(
      authProvider.token!,
      sessionId,
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ จบ Session สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showLogoutConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showCompleteSessionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จบ Session'),
        content: const Text('คุณต้องการจบ Session นี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('จบ Session'),
          ),
        ],
      ),
    );
  }
}