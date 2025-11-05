import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/checkpoint_provider.dart';
import 'providers/session_provider.dart';
import 'providers/nfc_provider.dart';
import 'providers/camera_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/checkpoint/checkpoint_list_screen.dart';
import 'screens/checkpoint/checkpoint_detail_screen.dart';
import 'screens/checkpoint/checkpoint_scan_screen.dart';
import 'screens/checkpoint/log_checkpoint_screen.dart';
import 'screens/session/session_history_screen.dart';
import 'screens/camera/camera_capture_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CheckpointProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => NfcProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: MaterialApp(
        title: 'NFC Event System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Splash Screen
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
          }

          // Login Screen
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }

          // Home Screen
          if (settings.name == '/home') {
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
          }

          // Checkpoint List Screen
          if (settings.name == '/checkpoints') {
            return MaterialPageRoute(
              builder: (context) => const CheckpointListScreen(),
            );
          }

          // Session History Screen
          if (settings.name == '/sessions') {
            return MaterialPageRoute(
              builder: (context) => const SessionHistoryScreen(),
            );
          }

          // Checkpoint Detail Screen
          if (settings.name == '/checkpoint-detail') {
            // ✅ รับ Map<String, dynamic>
            final checkpoint = settings.arguments as Map<String, dynamic>?;
            
            if (checkpoint == null) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('ข้อผิดพลาด')),
                  body: const Center(child: Text('ไม่พบข้อมูลจุดตรวจ')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (context) => CheckpointDetailScreen(checkpoint: checkpoint),
            );
          }

          // Checkpoint Scan Screen
          if (settings.name == '/checkpoint-scan') {
            final checkpoint = settings.arguments as Map<String, dynamic>?;
            
            if (checkpoint == null) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('ข้อผิดพลาด')),
                  body: const Center(child: Text('ไม่พบข้อมูลจุดตรวจ')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (context) => CheckpointScanScreen(checkpoint: checkpoint),
            );
          }

          // Log Checkpoint Screen
          if (settings.name == '/log-checkpoint') {
            final args = settings.arguments as Map<String, dynamic>?;
            
            if (args == null) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('ข้อผิดพลาด')),
                  body: const Center(child: Text('ไม่พบข้อมูล')),
                ),
              );
            }

            // ✅ ส่ง checkpointId และ nfcUid
            final checkpointId = args['checkpoint_id'] as int?;
            final nfcUid = args['nfc_uid'] as String?;
            
            if (checkpointId == null) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('ข้อผิดพลาด')),
                  body: const Center(child: Text('ไม่พบข้อมูลจุดตรวจ')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (context) => LogCheckpointScreen(
                checkpointId: checkpointId,
                nfcUid: nfcUid,
              ),
            );
          }

          // Camera Capture Screen
          if (settings.name == '/camera-capture') {
            // ✅ รับ callback function
            final args = settings.arguments as Map<String, dynamic>?;
            final onImageCaptured = args?['onImageCaptured'] as Function(File)?;
            
            if (onImageCaptured == null) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('ข้อผิดพลาด')),
                  body: const Center(child: Text('ไม่พบ callback function')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (context) => CameraCaptureScreen(
                onImageCaptured: onImageCaptured,
              ),
            );
          }

          // Default - Page Not Found
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('ไม่พบหน้า')),
              body: const Center(
                child: Text('ไม่พบหน้าที่ต้องการ'),
              ),
            ),
          );
        },
      ),
    );
  }
}