import 'package:flutter/material.dart';
import 'enter_carry_mark.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LecturerDashboard extends StatelessWidget {
  const LecturerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lecturer Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFFBFE8D7),
          ),
        ),
        backgroundColor: const Color(0xFF37474F),
        elevation: 2,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Color(0xFFFF0000),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF37474F), Color(0xFFBFE8D7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Welcome, Lecturer",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBFE8D7),
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: SizedBox(
                    width: 220,
                    height: 120,
                    child: _menuCard(
                      "Enter Carry Marks",
                      const Color(0xFF37474F),
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EnterCarryMark(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(String title, Color color, Function() onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFFBFE8D7),
            ),
          ),
        ),
      ),
    );
  }
}
