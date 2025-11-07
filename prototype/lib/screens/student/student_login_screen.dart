import 'package:flutter/material.dart';
import '../../models.dart';
import 'student_home_screen.dart';

/// Student login screen.
class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController(text: 'homelga');

  void _login() {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    final student = FakeDb.students
        .where((s) => s.id == id && s.password == password)
        .firstOrNull;

    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ID or password')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentHomeScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Students cannot sign up by themselves.\n'
              'They must be added by a teacher first.\n'
              'Default password is "homelga".',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
