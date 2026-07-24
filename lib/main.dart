import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:travelapp/blocs/user/user_bloc.dart';
import 'package:travelapp/repositories/firebase_options.dart';
import 'package:travelapp/repositories/notifications/notification_service.dart';
import 'package:travelapp/ui/emailVerificationPage.dart';
import 'package:travelapp/seed_data.dart';
import 'blocs/place/placeList_bloc.dart';
import 'blocs/trip/trip_bloc.dart';
import 'network_controller.dart';
import 'ui/Welcomepage.dart';
import 'ui/navigationPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<placeListBloc>(
            create: (BuildContext context) => placeListBloc()),
        BlocProvider<userBloc>(create: (context) => userBloc()),
        BlocProvider(
          create: (context) => tripBloc(),
        )
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const welcomePage(),
          '/home': (context) => navigationPage(
                isBackButtonClick: false,
                autoSelectedIndex: 0,
              ),
          '/emailVerification': (context) => const emailVerificationPage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Init Firebase with timeout
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));

      // Auto-seed data if not exists
      await autoSeedData();

      // Init Firebase Cloud Messaging
      await NotificationService().initialize();

      // Init Firebase In-App Messaging
      try {
        await FirebaseInAppMessaging.instance.setMessagesSuppressed(false);
        await FirebaseInAppMessaging.instance.triggerEvent('app_launch');
      } catch (e) {
        debugPrint('In-App Messaging error: $e');
      }
    } catch (e) {
      debugPrint('Firebase/Seed error: $e');
    }

    // Init network controller
    try {
      Get.put<NetworkController>(NetworkController(), permanent: true);
    } catch (e) {
      debugPrint('NetworkController error: $e');
    }

    // Check auth and navigate
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      String route;
      if (user != null && user.emailVerified) {
        route = '/home';
      } else {
        route = '/login';
      }

      if (mounted) {
        Get.offNamed(route);
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      if (mounted) {
        Get.offNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
