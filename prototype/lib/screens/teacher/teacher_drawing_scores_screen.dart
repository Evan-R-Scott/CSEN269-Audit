import 'package:flutter/material.dart';
import '../../models.dart';

/// Teacher view: grade drawing submissions with multiple questions.
class TeacherDrawingScoresScreen extends StatefulWidget {
  final Assignment assignment;

  const TeacherDrawingScoresScreen({super.key, required this.assignment});

  @override
  State<TeacherDrawingScoresScreen> createState() =>
      _TeacherDrawingScoresScreenState();
}

class _TeacherDrawingScoresScreenState
    extends State<TeacherDrawingScoresScreen> {
  int currentSubmissionIndex = 0;
  int currentQuestionIndex = 0;

  /// Parse drawing metadata from recordingNote field
  Map<int, String> _parseDrawingMetadata(String? metadata) {
    final result = <int, String>{};
    if (metadata == null || metadata.isEmpty) return result;

    try {
      final parts = metadata.split(',');
      for (var part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          final questionNum = int.tryParse(keyValue[0].replaceFirst('Q', ''));
          final drawingId = keyValue[1];
          if (questionNum != null) {
            result[questionNum] = drawingId;
          }
        }
      }
    } catch (e) {
      print('Error parsing drawing metadata: $e');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Get all drawing submissions for this assignment
    final submissions = FakeDb.submissions
        .where(
          (s) =>
              s.assignmentId == widget.assignment.id &&
              s.type == QuestionType.drawing,
        )
        .toList();

    if (submissions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Drawing Submissions')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No submissions yet for this assignment'),
          ),
        ),
      );
    }

    // Ensure indices are valid
    if (currentSubmissionIndex >= submissions.length) {
      currentSubmissionIndex = 0;
    }
    if (currentQuestionIndex >= widget.assignment.questions.length) {
      currentQuestionIndex = 0;
    }

    final currentSubmission = submissions[currentSubmissionIndex];
    final student = FakeDb.students.firstWhere(
      (s) => s.id == currentSubmission.studentId,
      orElse: () => Student(id: 'unknown', name: 'Unknown', className: ''),
    );

    // Parse all drawing IDs from metadata
    final drawingIds = _parseDrawingMetadata(currentSubmission.recordingNote);

    final currentQuestion = widget.assignment.questions.isNotEmpty
        ? widget.assignment.questions[currentQuestionIndex]
        : null;

    // Get the drawing for the current question
    final currentDrawingId = drawingIds[currentQuestionIndex];
    final imageData = currentDrawingId != null
        ? FakeDb.drawingImages[currentDrawingId]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grade Drawings'),
            Text(
              'Student ${currentSubmissionIndex + 1} of ${submissions.length}',
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
            // Student info header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Assignment: ${widget.assignment.title}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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
            // Questions navigation (if multiple questions)
            if (widget.assignment.questions.length > 1)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questions: ${widget.assignment.questions.length} total',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          widget.assignment.questions.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text('Q${index + 1}'),
                              onPressed: () {
                                setState(() => currentQuestionIndex = index);
                              },
                              backgroundColor: currentQuestionIndex == index
                                  ? Colors.blue
                                  : Colors.grey[300],
                              labelStyle: TextStyle(
                                color: currentQuestionIndex == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Current question display
            if (currentQuestion != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.amber[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            // Drawing image
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
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No drawing submitted for Question ${currentQuestionIndex + 1}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            // Grading section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Grade for Assignment',
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
                      if (score != null && score >= 0 && score <= 100) {
                        currentSubmission.score = score;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Feedback for Student',
                      border: const OutlineInputBorder(),
                      hintText:
                          'Provide feedback on all ${widget.assignment.questions.length} drawings...',
                    ),
                    controller: TextEditingController(
                      text: currentSubmission.comment ?? '',
                    ),
                    onChanged: (value) {
                      currentSubmission.comment = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Navigation buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentSubmissionIndex > 0
                            ? () {
                                setState(() => currentSubmissionIndex--);
                                currentQuestionIndex = 0;
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous Student'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Student grade saved!'),
                            ),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Grade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed:
                            currentSubmissionIndex < submissions.length - 1
                            ? () {
                                setState(() => currentSubmissionIndex++);
                                currentQuestionIndex = 0;
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next Student'),
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
