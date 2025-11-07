import 'package:flutter/material.dart';
import '../../models.dart';

/// Student answering MCQ assignments.
class StudentMcqAssignmentScreen extends StatefulWidget {
  final Assignment assignment;
  final Student student;

  const StudentMcqAssignmentScreen({
    super.key,
    required this.assignment,
    required this.student,
  });

  @override
  State<StudentMcqAssignmentScreen> createState() =>
      _StudentMcqAssignmentScreenState();
}

class _StudentMcqAssignmentScreenState
    extends State<StudentMcqAssignmentScreen> {
  late List<int?> selectedIndexes;

  @override
  void initState() {
    super.initState();
    selectedIndexes =
        List<int?>.filled(widget.assignment.questions.length, null);
  }

  void _submit() {
    if (selectedIndexes.any((i) => i == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    final answers = selectedIndexes.cast<int>().toList();

    int correct = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] ==
          widget.assignment.questions[i].correctIndex) {
        correct++;
      }
    }

    final score = ((correct / answers.length) * 100).round();

    // Remove old submission if exists, then add a new one.
    FakeDb.submissions.removeWhere(
      (s) =>
          s.assignmentId == widget.assignment.id &&
          s.studentId == widget.student.id,
    );

    FakeDb.submissions.add(
      Submission(
        assignmentId: widget.assignment.id,
        studentId: widget.student.id,
        type: QuestionType.mcq,
        mcqAnswers: answers,
        score: score,
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assignment Submitted'),
        content: Text('Your score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to assignments list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;

    return Scaffold(
      appBar: AppBar(
        title: Text(a.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: a.questions.length,
        itemBuilder: (_, index) {
          final q = a.questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}. ${q.text}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(q.options!.length, (optIndex) {
                      return RadioListTile<int>(
                        title: Text(q.options![optIndex]),
                        value: optIndex,
                        groupValue: selectedIndexes[index],
                        onChanged: (val) {
                          setState(() {
                            selectedIndexes[index] = val;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ),
    );
  }
}
