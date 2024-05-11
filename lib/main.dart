import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notification_project/config/router/app_router.dart';
import 'package:push_notification_project/config/theme/app_theme.dart';
import 'package:push_notification_project/presentation/notifications/notifications_bloc.dart';
import 'package:push_notification_project/presentation/provider/head_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();
  FirebaseMessaging.onBackgroundMessage(NotificationsBloc().firebaseMessagingBackgroundHandler);
  runApp(HeadProvider.initProvider(mainAppWidget: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}

