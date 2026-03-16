import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/audio_player_service.dart';
import 'services/app_config_service.dart';
import 'services/announcement_service.dart';
import 'services/notification_service.dart';
import 'blocs/player_bloc.dart';
import 'screens/main_player_screen.dart';
import 'themes/jfm_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const FmJRadioApp());
}

Future<void> _initializeServices() async {
  // Initialize App Config Service
  final appConfigService = AppConfigService();
  await appConfigService.initialize();
  
  // Initialize Announcement Service
  final announcementService = AnnouncementService();
  await announcementService.initialize();
  
  // Initialize Notification Service (Firebase - optional, won't break if not configured)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    print('Firebase/Notification service not initialized: $e');
    // Continue without notifications - app works fine without Firebase
  }
}

class FmJRadioApp extends StatelessWidget {
  const FmJRadioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize audio service
    final audioPlayerService = AudioPlayerService();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PlayerBloc(
            audioPlayerService: audioPlayerService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'FmJ Radio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const MainPlayerScreen(),
      ),
    );
  }
}
