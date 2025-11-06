import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('เมนูผู้ดูแลระบบ'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple,
                    child: Text(
                      user?.username?.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'Admin',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.role ?? 'Administrator',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Menu Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'จัดการระบบ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // NFC Management
          _buildMenuCard(
            context,
            icon: Icons.nfc,
            title: 'จัดการ NFC Tags',
            subtitle: 'เพิ่ม แก้ไข ลบ NFC Tags',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/admin-nfc'),
          ),

          // Checkpoint Management
          _buildMenuCard(
            context,
            icon: Icons.location_on,
            title: 'จัดการจุดตรวจ',
            subtitle: 'เพิ่ม แก้ไข ลบจุดตรวจ',
            color: Colors.orange,
            onTap: () {
              // TODO: ไปหน้าจัดการจุดตรวจ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),

          // User Management
          _buildMenuCard(
            context,
            icon: Icons.people,
            title: 'จัดการผู้ใช้',
            subtitle: 'เพิ่ม แก้ไข ลบผู้ใช้',
            color: Colors.green,
            onTap: () {
              // TODO: ไปหน้าจัดการผู้ใช้
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),

          // Reports
          _buildMenuCard(
            context,
            icon: Icons.analytics,
            title: 'รายงาน',
            subtitle: 'ดูรายงานและสถิติ',
            color: Colors.teal,
            onTap: () {
              // TODO: ไปหน้ารายงาน
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),

          const SizedBox(height: 24),

          // System Info
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'ระบบ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Settings
          _buildMenuCard(
            context,
            icon: Icons.settings,
            title: 'ตั้งค่า',
            subtitle: 'ตั้งค่าระบบ',
            color: Colors.grey,
            onTap: () {
              // TODO: ไปหน้าตั้งค่า
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}