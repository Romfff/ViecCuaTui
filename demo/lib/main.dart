import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'provider/auth_provider.dart';
import 'provider/job_provider.dart';
import 'provider/notification_provider.dart';
import 'screen/auth/login_screen.dart';
import 'screen/home/home_screen.dart';
import 'screen/recruiter/recruiter_home_screen.dart';
import 'screen/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ViecCuaTui',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        // Để AuthWrapper ở home để tự động điều hướng khi mở app
        home: const AuthWrapper(),
        routes: {
          '/login': (_) => const LoginScreen(),
          // Quan trọng: /home bây giờ cũng trỏ về AuthWrapper để nó tự quyết định giao diện theo Role
          '/home': (_) => const AuthWrapper(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.user != null) {
      // Nếu đã đăng nhập, kiểm tra Role
      if (auth.role == 'job_poster') {
        return const RecruiterHomeScreen();
      } else {
        return const HomeScreen();
      }
    } else {
      // Nếu chưa đăng nhập, về màn hình Login
      return const LoginScreen();
    }
  }
}
