import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableSound = true;
  bool _enableVibration = true;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        backgroundColor: AppConfig.primaryColor,
      ),
      body: ListView(
        children: [
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConfig.primaryColor,
                  AppConfig.secondaryColor,
                ],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'ผู้ใช้',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.organization ?? 'องค์กร',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App Settings Section
          _buildSectionHeader('การตั้งค่าแอพ'),
          _buildSwitchTile(
            title: 'แจ้งเตือน',
            subtitle: 'รับการแจ้งเตือนจากระบบ',
            value: _enableNotifications,
            icon: Icons.notifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'เสียง',
            subtitle: 'เปิดเสียงแจ้งเตือน',
            value: _enableSound,
            icon: Icons.volume_up,
            onChanged: (value) {
              setState(() {
                _enableSound = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'สั่น',
            subtitle: 'เปิดการสั่นเมื่อมีการแจ้งเตือน',
            value: _enableVibration,
            icon: Icons.vibration,
            onChanged: (value) {
              setState(() {
                _enableVibration = value;
              });
            },
          ),

          const Divider(height: 32),

          // Data Settings Section
          _buildSectionHeader('การจัดการข้อมูล'),
          _buildSwitchTile(
            title: 'ซิงค์อัตโนมัติ',
            subtitle: 'ซิงค์ข้อมูลกับเซิร์ฟเวอร์อัตโนมัติ',
            value: _autoSync,
            icon: Icons.sync,
            onChanged: (value) {
              setState(() {
                _autoSync = value;
              });
            },
          ),
          _buildListTile(
            title: 'ล้างข้อมูลแคช',
            subtitle: 'ลบข้อมูลที่เก็บไว้ชั่วคราว',
            icon: Icons.cleaning_services,
            onTap: () => _showClearCacheDialog(),
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionHeader('เกี่ยวกับ'),
          _buildListTile(
            title: 'เวอร์ชัน',
            subtitle: AppConfig.appVersion,
            icon: Icons.info,
            onTap: () => _showAboutDialog(),
          ),
          _buildListTile(
            title: 'เงื่อนไขการใช้งาน',
            subtitle: 'อ่านเงื่อนไขการใช้งาน',
            icon: Icons.description,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ฟีเจอร์กำลังพัฒนา'),
                ),
              );
            },
          ),
          _buildListTile(
            title: 'นโยบายความเป็นส่วนตัว',
            subtitle: 'อ่านนโยบายความเป็นส่วนตัว',
            icon: Icons.privacy_tip,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ฟีเจอร์กำลังพัฒนา'),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(),
              icon: const Icon(Icons.logout),
              label: const Text('ออกจากระบบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppConfig.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConfig.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConfig.primaryColor,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConfig.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างข้อมูลแคช'),
        content: const Text(
          'คุณต้องการล้างข้อมูลแคชทั้งหมดหรือไม่?\n\nข้อมูลที่ดาวน์โหลดไว้จะถูกลบ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ล้างข้อมูลแคชสำเร็จ'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: const Text('ล้างข้อมูล'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppConfig.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.nfc,
          size: 40,
          color: Colors.white,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'ระบบบันทึกเหตุการณ์ด้วย NFC\n\n'
          'พัฒนาโดยทีมพัฒนา\n'
          '© 2024 All rights reserved',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}