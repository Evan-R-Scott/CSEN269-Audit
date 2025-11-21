import 'package:flutter/material.dart';
import '../../models.dart';
import 'teacher_scores_screen.dart';

/// Teacher view: single assignment → questions + Scores button.
class TeacherAssignmentDetailScreen extends StatefulWidget {
  final Assignment assignment;
  final VoidCallback onChanged;

  const TeacherAssignmentDetailScreen({
    super.key,
    required this.assignment,
    required this.onChanged,
  });

  @override
  State<TeacherAssignmentDetailScreen> createState() =>
      _TeacherAssignmentDetailScreenState();
}

class _TeacherAssignmentDetailScreenState
    extends State<TeacherAssignmentDetailScreen> {
  void _addQuestion() async {
    if (widget.assignment.type == QuestionType.mcq) {
      final textController = TextEditingController();
      final optionControllers = List.generate(
        4,
        (_) => TextEditingController(),
      );
      int correctIndex = 0;

      final q = await showDialog<Question>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Add MCQ Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Question Text',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Options:'),
                  const SizedBox(height: 8),
                  for (int i = 0; i < 4; i++)
                    TextField(
                      controller: optionControllers[i],
                      decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                    ),
                  const SizedBox(height: 12),
                  const Text('Correct Option:'),
                  DropdownButton<int>(
                    value: correctIndex,
                    items: List.generate(
                      4,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text('Option ${index + 1}'),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() => correctIndex = val);
                      }
                    },
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
                  if (textController.text.trim().isEmpty ||
                      optionControllers.any((c) => c.text.trim().isEmpty)) {
                    return;
                  }
                  final q = Question(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: textController.text.trim(),
                    type: QuestionType.mcq,
                    options: optionControllers
                        .map((c) => c.text.trim())
                        .toList(),
                    correctIndex: correctIndex,
                  );
                  Navigator.pop(context, q);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      );

      if (q != null) {
        setState(() {
          widget.assignment.questions.add(q);
        });
        widget.onChanged();
      }
    } else if (widget.assignment.type == QuestionType.recording) {
      final textController = TextEditingController();
      final q = await showDialog<Question>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Recording Question'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Question Text'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isEmpty) return;
                final q = Question(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: textController.text.trim(),
                  type: QuestionType.recording,
                );
                Navigator.pop(context, q);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (q != null) {
        setState(() {
          widget.assignment.questions.add(q);
        });
        widget.onChanged();
      }
    } else if (widget.assignment.type == QuestionType.drawing) {
      final textController = TextEditingController();
      final q = await showDialog<Question>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Drawing Question'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Drawing Prompt'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isEmpty) return;
                final q = Question(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: textController.text.trim(),
                  type: QuestionType.drawing,
                );
                Navigator.pop(context, q);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (q != null) {
        setState(() {
          widget.assignment.questions.add(q);
        });
        widget.onChanged();
      }
    }
  }

  void _viewScores() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherScoresScreen(assignment: widget.assignment),
      ),
    ).then((_) {
      // Refresh when coming back from scores screen
      setState(() {});
    });
  }

  String _getQuestionType(QuestionType type) {
    if (type == QuestionType.mcq) {
      return 'MCQ';
    } else if (type == QuestionType.recording) {
      return 'Recording';
    } else {
      return 'Drawing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;

    // Count submissions for this assignment
    final submissionCount = FakeDb.submissions
        .where((s) => s.assignmentId == a.id)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(a.title),
        actions: [
          // Scores button with submission badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: _viewScores,
                icon: const Icon(Icons.assignment_turned_in),
                label: Text(
                  'View Submissions (${submissionCount})',
                  style: const TextStyle(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: submissionCount > 0
                      ? Colors.blue[700]
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(a.text),
            subtitle: Text(
              'Posted: ${a.postedDate.toLocal().toString().split(' ').first} • '
              'Due: ${a.dueDate.toLocal().toString().split(' ').first}',
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: a.questions.length,
              itemBuilder: (_, index) {
                final q = a.questions[index];
                return ListTile(
                  leading: Text('Q${index + 1}'),
                  title: Text(q.text),
                  subtitle: Text(_getQuestionType(q.type)),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
      ),
    );
  }
}
