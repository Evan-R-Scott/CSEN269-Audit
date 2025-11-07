import 'package:flutter/material.dart';
import '../../models.dart';
import 'teacher_students_tab.dart';
import 'teacher_assignments_tab.dart';

/// Teacher home screen with bottom navigation: Students / Assignments.
class TeacherHomeScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherHomeScreen({super.key, required this.teacher});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _tabIndex = 0;

  void _logout() {
    // Go back all the way to the first screen.
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _changePassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        widget.teacher.password = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TeacherStudentsTab(onChanged: () => setState(() {})),
      TeacherAssignmentsTab(onChanged: () => setState(() {})),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher: ${widget.teacher.username}'),
        actions: [
          IconButton(
            onPressed: _changePassword,
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
        ],
      ),
    );
  }
}
