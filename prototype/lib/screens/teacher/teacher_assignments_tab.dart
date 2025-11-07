import 'package:flutter/material.dart';
import '../../models.dart';
import 'teacher_assignment_detail_screen.dart';

/// Teacher tab: list & create assignments.
class TeacherAssignmentsTab extends StatefulWidget {
  final VoidCallback onChanged;

  const TeacherAssignmentsTab({super.key, required this.onChanged});

  @override
  State<TeacherAssignmentsTab> createState() => _TeacherAssignmentsTabState();
}

class _TeacherAssignmentsTabState extends State<TeacherAssignmentsTab> {
  void _addAssignment() async {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    QuestionType type = QuestionType.mcq;

    final newAssignment = await showDialog<Assignment>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('New Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: 'Assignment Title'),
                ),
                TextField(
                  controller: textController,
                  decoration:
                      const InputDecoration(labelText: 'Assignment Text'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Question Type:'),
                    const SizedBox(width: 8),
                    DropdownButton<QuestionType>(
                      value: type,
                      items: const [
                        DropdownMenuItem(
                          value: QuestionType.mcq,
                          child: Text('Multiple Choice'),
                        ),
                        DropdownMenuItem(
                          value: QuestionType.recording,
                          child: Text('Recording'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => type = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Due date: '),
                    Text(dueDate.toLocal().toString().split(' ').first),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          initialDate: dueDate,
                        );
                        if (picked != null) {
                          setStateDialog(() => dueDate = picked);
                        }
                      },
                      child: const Text('Pick'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final a = Assignment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  text: textController.text.trim(),
                  postedDate: DateTime.now(),
                  dueDate: dueDate,
                  type: type,
                  questions: [],
                );
                Navigator.pop(context, a);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (newAssignment != null) {
      setState(() {
        FakeDb.assignments.add(newAssignment);
      });
      widget.onChanged();
    }
  }

  void _openAssignment(Assignment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherAssignmentDetailScreen(
          assignment: a,
          onChanged: () {
            setState(() {});
            widget.onChanged();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = FakeDb.assignments;
    return Scaffold(
      body: ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (_, index) {
          final a = assignments[index];
          return ListTile(
            leading: const Icon(Icons.assignment),
            title: Text(a.title),
            subtitle: Text(
              'Due: ${a.dueDate.toLocal().toString().split(' ').first} '
              '• Type: ${a.type == QuestionType.mcq ? "MCQ" : "Recording"}',
            ),
            onTap: () => _openAssignment(a),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAssignment,
        label: const Text('Add Assignment'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
