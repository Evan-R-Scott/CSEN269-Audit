import 'package:flutter/material.dart';
import '../../models.dart';

/// Teacher view: list of submissions, grade and comment.
class TeacherScoresScreen extends StatelessWidget {
  final Assignment assignment;

  const TeacherScoresScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final subs = FakeDb.submissions
        .where((s) => s.assignmentId == assignment.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Scores: ${assignment.title}'),
      ),
      body: ListView.builder(
        itemCount: subs.length,
        itemBuilder: (_, index) {
          final s = subs[index];
          final student = FakeDb.students
              .firstWhere((st) => st.id == s.studentId);
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(student.name),
            subtitle: Text(
              'Score: ${s.score?.toString() ?? "Not graded"}'
              '${s.comment != null ? " • Comment: ${s.comment}" : ""}',
            ),
            trailing: assignment.type == QuestionType.recording
                ? IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      // Stub: in a real app we would play audio.
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Play Recording'),
                          content: Text(
                            s.recordingNote ??
                                'This is a placeholder for the recording.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : null,
            onTap: () async {
              final scoreController = TextEditingController(
                text: s.score?.toString() ?? '',
              );
              final commentController = TextEditingController(
                text: s.comment ?? '',
              );
              final updated = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Grade: ${student.name}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: scoreController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Score',
                        ),
                      ),
                      TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Comment',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (updated == true) {
                final parsedScore = int.tryParse(scoreController.text.trim());
                s.score = parsedScore;
                s.comment = commentController.text.trim();
                (context as Element).markNeedsBuild();
              }
            },
          );
        },
      ),
    );
  }
}
