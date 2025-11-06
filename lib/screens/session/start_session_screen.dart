import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/checkpoint_provider.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    await sessionProvider.loadActiveSession();

    if (!mounted) return;

    // ถ้ามี active session แล้ว ไปหน้าจุดตรวจเลย
    if (sessionProvider.activeSession != null) {
      Navigator.pushReplacementNamed(context, '/checkpoints');
    }
  }

  Future<void> _startSession() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final checkpointProvider = Provider.of<CheckpointProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. สร้าง session
      final result = await sessionProvider.createSession(authProvider.token!);

      if (!mounted) return;

      if (result['success']) {
        // 2. โหลดจุดตรวจ
        await checkpointProvider.loadCheckpoints(authProvider.token!);

        if (!mounted) return;

        // 3. แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ เริ่ม Session สำเร็จ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 4. ไปหน้าจุดตรวจ
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        Navigator.pushReplacementNamed(context, '/checkpoints');
      } else {
        _showErrorDialog('ไม่สามารถสร้าง Session ได้', result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('เกิดข้อผิดพลาด', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เริ่มการตรวจ'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          final activeSession = sessionProvider.activeSession;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ไอคอน
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // หัวข้อ
                  const Text(
                    'เริ่มการตรวจจุด',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // คำอธิบาย
                  Text(
                    activeSession != null
                        ? 'คุณมี Session ที่กำลังดำเนินการอยู่'
                        : 'เริ่มต้น Session ใหม่เพื่อเริ่มการตรวจจุด',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ข้อมูล Session (ถ้ามี)
                  if (activeSession != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Session ID:'),
                                Text(
                                  '#${activeSession['id']?.toString() ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (activeSession['progress'] != null) ...[
                              const Divider(),
                              Builder(
                                builder: (context) {
                                  final progress = activeSession['progress'] 
                                      as Map<String, dynamic>;
                                  final completed = progress['completed'] ?? 0;
                                  final total = progress['total'] ?? 1;
                                  
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: 
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('ความคืบหน้า:'),
                                          Text(
                                            '$completed/$total',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: completed / total.toDouble(),
                                        backgroundColor: Colors.grey[300],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ปุ่มเริ่ม Session / ดำเนินการต่อ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : (activeSession != null
                              ? () => Navigator.pushReplacementNamed(
                                    context,
                                    '/checkpoints',
                                  )
                              : _startSession),
                      icon: Icon(
                        activeSession != null
                            ? Icons.arrow_forward
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        activeSession != null
                            ? 'ดำเนินการต่อ'
                            : 'เริ่ม Session ใหม่',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ปุ่มกลับ
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('กลับ'),
                  ),

                  // Loading indicator
                  if (_isLoading) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}