import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'features/events/event_list_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AtmosphereAdminApp());
}

class AtmosphereAdminApp extends StatelessWidget {
  const AtmosphereAdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fs Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      defaultTransition: Transition.cupertino,
      home: const EventListScreen(),
    );
  }
}
