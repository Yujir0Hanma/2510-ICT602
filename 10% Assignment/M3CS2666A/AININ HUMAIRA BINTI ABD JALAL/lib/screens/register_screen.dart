import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _studentId = TextEditingController();
  final _name = TextEditingController();

  String _role = 'student';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF37474F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37474F),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Back",
            style: TextStyle(
              color: Color(0xFFBFE8D7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: const Text(
          "Register Account",
          style: TextStyle(
            color: Color(0xFFBFE8D7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: ["admin", "lecturer", "student"]
                        .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.toUpperCase()),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _role = v!),
                    decoration: const InputDecoration(labelText: "Select Role"),
                  ),
                  if (_role == 'student') ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: _studentId,
                      decoration:
                      const InputDecoration(labelText: "Student ID"),
                    ),
                  ],
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF8B0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                        setState(() => loading = true);
                        final err = await auth.registerUser(
                          _email.text.trim(),
                          _password.text.trim(),
                          _role,
                          name: _name.text.trim(),
                          studentId: _role == 'student'
                              ? _studentId.text.trim()
                              : null,
                        );
                        setState(() => loading = false);
                        if (err != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: loading
                          ? const CircularProgressIndicator(
                        color: Color(0xFFBFE8D7),
                      )
                          : const Text(
                        "Register",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
