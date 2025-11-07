import 'package:flutter/material.dart';
import '../../models.dart';

/// Teacher tab: manage Class 1 / Class 2 students.
class TeacherStudentsTab extends StatefulWidget {
  final VoidCallback onChanged;

  const TeacherStudentsTab({super.key, required this.onChanged});

  @override
  State<TeacherStudentsTab> createState() => _TeacherStudentsTabState();
}

class _TeacherStudentsTabState extends State<TeacherStudentsTab> {
  String selectedClass = 'Class 1';

  void _addStudent() async {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final classController = TextEditingController(text: selectedClass);

    final newStudent = await showDialog<Student>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: classController,
              decoration:
                  const InputDecoration(labelText: 'Class (Class 1 or Class 2)'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Default password will be "homelga".',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (idController.text.trim().isEmpty ||
                  nameController.text.trim().isEmpty) {
                return;
              }
              final s = Student(
                id: idController.text.trim(),
                name: nameController.text.trim(),
                className: classController.text.trim(),
              );
              Navigator.pop(context, s);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (newStudent != null) {
      setState(() {
        FakeDb.students.add(newStudent);
      });
      widget.onChanged();
    }
  }

  void _removeStudent(Student s) {
    setState(() {
      FakeDb.students.removeWhere((st) => st.id == s.id);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final students = FakeDb.students
        .where((s) => s.className == selectedClass)
        .toList();

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Class 1'),
              selected: selectedClass == 'Class 1',
              onSelected: (_) => setState(() => selectedClass = 'Class 1'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Class 2'),
              selected: selectedClass == 'Class 2',
              onSelected: (_) => setState(() => selectedClass = 'Class 2'),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (_, index) {
              final s = students[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text('${s.name} (${s.id})'),
                subtitle: Text(s.className),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeStudent(s),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: _addStudent,
              label: const Text('Add Student'),
              icon: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
