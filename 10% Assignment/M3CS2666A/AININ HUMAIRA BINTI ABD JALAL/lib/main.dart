import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

//services
import 'services/auth_service.dart';
import 'models/user_model.dart';

//screens pages
import 'screens/login_screen.dart';
import 'screens/admin_landing.dart';
import 'screens/lecturer_dashboard.dart';
import 'screens/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ICT602 Assignment App',
        theme: ThemeData(
          primaryColor: const Color(0xFF3F51B5),
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3F51B5),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder<AuthUser?>(
      stream: auth.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3F51B5)),
                  ),
                  SizedBox(height: 14),
                  Text("Loading dashboard...", style: TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) return LoginScreen();

        switch (user.role.trim().toLowerCase()) {
          case 'admin':
            return AdminLanding();
          case 'lecturer':
            return LecturerDashboard();
          case 'student':
            return StudentDashboard();
          default:
            return LoginScreen();
        }
      },
    );
  }
}
