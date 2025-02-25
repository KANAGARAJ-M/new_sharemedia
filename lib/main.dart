import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_sharemedia/firebase_options.dart';
import 'package:new_sharemedia/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:new_sharemedia/components/life_cycle_event_handler.dart';
import 'package:new_sharemedia/landing/landing_page.dart';
import 'package:new_sharemedia/screens/mainscreen.dart';
import 'package:new_sharemedia/services/user_service.dart';
import 'package:new_sharemedia/utils/config.dart';
import 'package:new_sharemedia/utils/constants.dart';
import 'package:new_sharemedia/utils/providers.dart';
import 'package:new_sharemedia/view_models/theme/theme_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.android,
    );
     final notificationService = NotificationService();
  await notificationService.initialize();
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Handle initialization error gracefully, if needed
  }

  // WidgetsFlutterBinding.ensureInitialized();
  // await Config.initFirebase();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, Widget? child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: notifier.themeMode,
          theme: Constants.lightTheme,
          darkTheme: Constants.darkTheme,
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return TabScreen();
                } else
                  return Landing();
              }),
            ),
          );
        },
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(
        theme.textTheme,
      ),
    );
  }
}



///flutter pub run change_app_package_name:main sharemedia.kaizen.com
///flutter pub run change_app_package_name:main mskp.tamilanproject.sharemediapro.xyz
