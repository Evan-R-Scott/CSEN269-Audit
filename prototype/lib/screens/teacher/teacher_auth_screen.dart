import 'package:flutter/material.dart';
import '../../models.dart';
import 'teacher_home_screen.dart';

/// Teacher login / sign-up screen.
class TeacherAuthScreen extends StatefulWidget {
  const TeacherAuthScreen({super.key});

  @override
  State<TeacherAuthScreen> createState() => _TeacherAuthScreenState();
}

class _TeacherAuthScreenState extends State<TeacherAuthScreen> {
  bool isLogin = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleSubmit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    if (isLogin) {
      // Login existing teacher
      final teacher = FakeDb.teachers
          .where((t) => t.username == username && t.password == password)
          .firstOrNull;
      if (teacher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherHomeScreen(teacher: teacher),
        ),
      );
    } else {
      // Sign up new teacher
      final exists = FakeDb.teachers.any((t) => t.username == username);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
        return;
      }
      final newTeacher = Teacher(username: username, password: password);
      FakeDb.teachers.add(newTeacher);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherHomeScreen(teacher: newTeacher),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isLogin ? 'Teacher Login' : 'Teacher Sign Up';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [isLogin, !isLogin],
              onPressed: (index) {
                setState(() {
                  isLogin = index == 0;
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Login'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Sign Up'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
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
                onPressed: _handleSubmit,
                child: Text(isLogin ? 'Login' : 'Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
