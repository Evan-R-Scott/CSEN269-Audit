import 'package:flutter/material.dart';
import 'teacher/teacher_auth_screen.dart';
import 'student/student_login_screen.dart';

/// Landing screen where user chooses Teacher or Student.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher–Student App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose user type',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherAuthScreen(),
                    ),
                  );
                },
                child: const Text('I am a Teacher'),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentLoginScreen(),
                    ),
                  );
                },
                child: const Text('I am a Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
