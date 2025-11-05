import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/nfc_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/nfc_status_widget.dart';

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
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    debugPrint('╔════════════════════════════════════════╗');
    debugPrint('║         HOME SCREEN - LOADING          ║');
    debugPrint('╚════════════════════════════════════════╝');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);

    debugPrint('🔐 Auth Status:');
    debugPrint('   - isLoggedIn: ${authProvider.isLoggedIn}');
    debugPrint('   - user: ${authProvider.user?.username ?? "null"}');
    debugPrint('   - token: ${authProvider.token != null ? "exists (${authProvider.token!.length} chars)" : "null"}');

    // Refresh user data
    await authProvider.refreshUser();

    // Load active session
    await sessionProvider.loadActiveSession();

    // Check NFC availability
    await nfcProvider.checkNfcAvailability();

    debugPrint('✅ Home data loaded');
  }

  Future<void> _logout() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _navigateToHistory() {
    // Navigate to history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์ประวัติกำลังพัฒนา'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSettings() {
    // Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์ตั้งค่ากำลังพัฒนา'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCheckpointList() {
    debugPrint('🔄 Navigating to checkpoint list...');
    debugPrint('   - Current route: ${ModalRoute.of(context)?.settings.name}');
    
    // Navigate without removing current route from stack
    Navigator.pushNamed(context, '/checkpoint_list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        backgroundColor: AppConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer3<AuthProvider, SessionProvider, NfcProvider>(
          builder: (context, authProvider, sessionProvider, nfcProvider, child) {
            if (authProvider.isLoading || sessionProvider.isLoading) {
              return const Center(child: LoadingWidget());
            }

            final user = authProvider.user;
            final activeSession = sessionProvider.activeSession;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppConfig.primaryColor,
                            AppConfig.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppConfig.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'สวัสดี!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.fullName ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.organization ?? 'Organization',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // NFC Status
                    const NfcStatusWidget(),

                    const SizedBox(height: 24),

                    // Active Session Card
                    if (activeSession != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConfig.infoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppConfig.infoColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  color: AppConfig.infoColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'รอบการตรวจที่กำลังดำเนินการ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('รหัสรอบ:'),
                                Text(
                                  '#${activeSession.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: activeSession.totalCheckpoints > 0
                                  ? activeSession.completedCheckpoints /
                                      activeSession.totalCheckpoints
                                  : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Menu Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          icon: Icons.play_circle_outline,
                          title: 'เริ่มรอบการตรวจ',
                          subtitle: 'เริ่มรอบการตรวจใหม่',
                          color: AppConfig.successColor,
                          onTap: _navigateToCheckpointList,
                        ),
                        _buildMenuCard(
                          icon: Icons.history,
                          title: 'ประวัติ',
                          subtitle: 'ดูประวัติการตรวจ',
                          color: AppConfig.infoColor,
                          onTap: _navigateToHistory,
                        ),
                        _buildMenuCard(
                          icon: Icons.location_on,
                          title: 'จุดตรวจ',
                          subtitle: 'รายการจุดตรวจทั้งหมด',
                          color: AppConfig.warningColor,
                          onTap: _navigateToCheckpointList,
                        ),
                        _buildMenuCard(
                          icon: Icons.settings,
                          title: 'ตั้งค่า',
                          subtitle: 'ตั้งค่าแอพพลิเคชัน',
                          color: Colors.grey[700]!,
                          onTap: _navigateToSettings,
                        ),
                      ],
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

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}