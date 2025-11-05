// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/checkpoint_provider.dart';
import 'providers/session_provider.dart';
import 'providers/nfc_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/event_provider.dart';

// ✅ แก้ไข import paths ให้ถูกต้อง
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/checkpoint/checkpoint_list_screen.dart';
import 'screens/checkpoint/checkpoint_detail_screen.dart';
import 'screens/checkpoint/checkpoint_scan_screen.dart';
import 'screens/camera/camera_capture_screen.dart';
import 'screens/event/event_note_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

import 'models/checkpoint_model.dart';
import 'models/session_model.dart';
import 'models/nfc_scan_result.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

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
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppConfig.primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConfig.primaryColor,
            primary: AppConfig.primaryColor,
            secondary: AppConfig.secondaryColor,
          ),
          scaffoldBackgroundColor: AppConfig.backgroundColor,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          // ✅ แก้ไข CardTheme เป็น CardThemeData
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
          fontFamily: 'Sarabun',
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            case '/checkpoint_list':
              return MaterialPageRoute(
                builder: (_) => const CheckpointListScreen(),
              );
            case '/checkpoint_detail':
              final checkpoint = settings.arguments as CheckpointModel;
              return MaterialPageRoute(
                builder: (_) => CheckpointDetailScreen(
                  checkpoint: checkpoint,
                ),
              );
            case '/checkpoint_scan':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => CheckpointScanScreen(
                  checkpoint: args['checkpoint'] as CheckpointModel,
                  session: args['session'] as SessionModel,
                ),
              );
            case '/camera_capture':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => CameraCaptureScreen(
                  checkpoint: args['checkpoint'] as CheckpointModel,
                  session: args['session'] as SessionModel,
                  scanResult: args['scan_result'] as NfcScanResult,
                ),
              );
            case '/event_note':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => EventNoteScreen(
                  checkpoint: args['checkpoint'] as CheckpointModel,
                  session: args['session'] as SessionModel,
                  scanResult: args['scan_result'] as NfcScanResult,
                  imagePath: args['image_path'] as String?,
                ),
              );
            case '/history':
              return MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              );
            case '/settings':
              return MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}