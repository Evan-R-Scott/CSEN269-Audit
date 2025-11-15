import 'package:flutter/material.dart';
import '../../models.dart';

/// Teacher view: grade drawing submissions.
class TeacherDrawingScoresScreen extends StatefulWidget {
  final Assignment assignment;

  const TeacherDrawingScoresScreen({super.key, required this.assignment});

  @override
  State<TeacherDrawingScoresScreen> createState() =>
      _TeacherDrawingScoresScreenState();
}

class _TeacherDrawingScoresScreenState
    extends State<TeacherDrawingScoresScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // DEBUG LOGGING
    debugPrint('\n\n=== TEACHER DRAWING SCREEN DEBUG ===');
    debugPrint('Assignment ID: ${widget.assignment.id}');
    debugPrint('Assignment Type: ${widget.assignment.type}');
    debugPrint('Total submissions in DB: ${FakeDb.submissions.length}');
    for (var i = 0; i < FakeDb.submissions.length; i++) {
      final sub = FakeDb.submissions[i];
      print(
        '  [$i] assignmentId=${sub.assignmentId}, studentId=${sub.studentId}, '
        'type=${sub.type}, drawingImageId=${sub.drawingImageId}',
      );
    }

    print('\nFiltering for this assignment...');
    final allForAssignment = FakeDb.submissions
        .where((s) => s.assignmentId == widget.assignment.id)
        .toList();
    print('Submissions for assignment: ${allForAssignment.length}');
    for (var sub in allForAssignment) {
      print(
        '  - type=${sub.type}, isDrawing=${sub.type == QuestionType.drawing}',
      );
    }

    final submissions = FakeDb.submissions
        .where(
          (s) =>
              s.assignmentId == widget.assignment.id &&
              s.type == QuestionType.drawing,
        )
        .toList();

    print('Drawing submissions after filter: ${submissions.length}\n');

    if (submissions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Drawing Submissions')),
        body: const Center(child: Text('No submissions yet')),
      );
    }

    final currentSubmission = submissions[currentIndex];
    final student = FakeDb.students.firstWhere(
      (s) => s.id == currentSubmission.studentId,
      orElse: () => Student(id: 'unknown', name: 'Unknown', className: ''),
    );

    final imageData = currentSubmission.drawingImageId != null
        ? FakeDb.drawingImages[currentSubmission.drawingImageId]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Drawing Submissions'),
            Text(
              '${currentIndex + 1} of ${submissions.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${student.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${student.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (currentSubmission.score != null)
                    Chip(
                      label: Text(
                        'Score: ${currentSubmission.score}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    )
                  else
                    const Chip(
                      label: Text(
                        'Not Graded',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                ],
              ),
            ),
            if (imageData != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => _showImageFullscreen(imageData),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(imageData),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No image available'),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grade This Submission',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Score (0-100)',
                      border: const OutlineInputBorder(),
                      hintText: currentSubmission.score?.toString() ?? '0',
                    ),
                    controller: TextEditingController(
                      text: currentSubmission.score?.toString() ?? '',
                    ),
                    onChanged: (value) {
                      final score = int.tryParse(value);
                      if (score != null) {
                        currentSubmission.score = score;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Feedback',
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your feedback for the student...',
                    ),
                    controller: TextEditingController(
                      text: currentSubmission.comment ?? '',
                    ),
                    onChanged: (value) {
                      currentSubmission.comment = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentIndex > 0
                            ? () => setState(() => currentIndex--)
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Submission saved!')),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: currentIndex < submissions.length - 1
                            ? () => setState(() => currentIndex++)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageFullscreen(dynamic imageData) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: InteractiveViewer(child: Image.memory(imageData))),
    );
  }
}
