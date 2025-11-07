import 'package:flutter/material.dart';
import '../../models.dart';
import 'student_assignments_tab.dart';

/// Student home: bottom navigation with Math Game (stub) + Assignments.
class StudentHomeScreen extends StatefulWidget {
  final Student student;

  const StudentHomeScreen({super.key, required this.student});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _tabIndex = 0;

  void _logout() {
    // Go back to the very first screen (role selection).
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _changePassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        widget.student.password = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Center(child: Text('Math Game (coming soon)')),
      StudentAssignmentsTab(student: widget.student),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Student: ${widget.student.name}'),
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
            icon: Icon(Icons.videogame_asset),
            label: 'Math Game',
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
