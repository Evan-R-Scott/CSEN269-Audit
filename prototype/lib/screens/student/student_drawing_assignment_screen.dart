import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../models.dart';
import '../widgets/drawing_canvas_widget.dart';

/// Student answering drawing assignments with multiple questions.
class StudentDrawingAssignmentScreen extends StatefulWidget {
  final Assignment assignment;
  final Student student;

  const StudentDrawingAssignmentScreen({
    super.key,
    required this.assignment,
    required this.student,
  });

  @override
  State<StudentDrawingAssignmentScreen> createState() =>
      _StudentDrawingAssignmentScreenState();
}

class _StudentDrawingAssignmentScreenState
    extends State<StudentDrawingAssignmentScreen> {
  int currentQuestionIndex = 0;
  final Map<int, String> submittedDrawingIds =
      {}; // Maps question index to drawing ID
  bool isSubmittingAssignment = false;
  GlobalKey<DrawingCanvasState>? canvasKey;

  @override
  void initState() {
    super.initState();
    _loadExistingSubmissions();
  }

  void _loadExistingSubmissions() {
    // Find submissions that match BOTH assignment AND this student
    final matchingSubmissions = FakeDb.submissions
        .where(
          (s) =>
              s.assignmentId == widget.assignment.id &&
              s.studentId == widget.student.id,
        )
        .toList();

    if (matchingSubmissions.isNotEmpty) {
      final existingSubmission =
          matchingSubmissions.last; // Get the most recent one

      if (existingSubmission.drawingImageId != null &&
          existingSubmission.drawingImageId!.isNotEmpty &&
          existingSubmission.recordingNote != null &&
          existingSubmission.recordingNote!.isNotEmpty) {
        // Load their drawing IDs
        final drawingIds = _parseDrawingMetadata(
          existingSubmission.recordingNote,
        );
        if (drawingIds.length == widget.assignment.questions.length) {
          isSubmittingAssignment = true;
          print(
            'DEBUG: Student ${widget.student.id} already submitted, showing gallery',
          );
        }
      }
    }
  }

  /// Parse drawing metadata to get all drawing IDs
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

  void _onImageGenerated(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Preview Drawing'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: Image.memory(imageData),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitThisDrawing(imageData);
            },
            child: const Text('Submit This Drawing'),
          ),
        ],
      ),
    );
  }

  void _submitThisDrawing(Uint8List imageData) {
    // Generate ID for this specific drawing
    final drawingId = FakeDb.generateDrawingId();
    FakeDb.drawingImages[drawingId] = imageData;

    setState(() {
      submittedDrawingIds[currentQuestionIndex] = drawingId;
    });

    // Clear canvas for next question
    canvasKey?.currentState?.clearCanvas();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Drawing ${currentQuestionIndex + 1} saved! '
          '${currentQuestionIndex + 1 < widget.assignment.questions.length ? 'Next question ->' : 'Ready to submit!'}',
        ),
      ),
    );

    // Auto-advance to next question if available
    if (currentQuestionIndex + 1 < widget.assignment.questions.length) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => currentQuestionIndex++);
      });
    }
  }

  void _submitEntireAssignment() {
    if (submittedDrawingIds.length != widget.assignment.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all ${widget.assignment.questions.length} drawings before submitting.',
          ),
        ),
      );
      return;
    }

    // Store all drawing IDs in recordingNote field as JSON metadata
    // Format: "Q0:id1,Q1:id2,Q2:id3"
    final drawingMetadata = submittedDrawingIds.entries
        .map((e) => 'Q${e.key}:${e.value}')
        .join(',');

    // Use first drawing ID as the main one
    final firstDrawingId = submittedDrawingIds[0];
    if (firstDrawingId == null) return;

    // Remove old submission if exists
    FakeDb.submissions.removeWhere(
      (s) =>
          s.assignmentId == widget.assignment.id &&
          s.studentId == widget.student.id,
    );

    // Add new submission with all drawing IDs stored as metadata
    FakeDb.submissions.add(
      Submission(
        assignmentId: widget.assignment.id,
        studentId: widget.student.id,
        type: QuestionType.drawing,
        drawingImageId: firstDrawingId,
        recordingNote: drawingMetadata, // Store all drawing IDs as metadata
        submittedAt: DateTime.now(),
        score: null,
        comment: null,
      ),
    );

    setState(() {
      isSubmittingAssignment = true;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assignment Submitted'),
        content: Text(
          'All ${widget.assignment.questions.length} drawings submitted successfully!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() => currentQuestionIndex--);
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < widget.assignment.questions.length - 1) {
      if (submittedDrawingIds.containsKey(currentQuestionIndex)) {
        setState(() => currentQuestionIndex++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please submit this drawing before continuing.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check current submission status on every build
    final currentSubmission = FakeDb.submissions.firstWhere(
      (s) =>
          s.assignmentId == widget.assignment.id &&
          s.studentId == widget.student.id &&
          s.drawingImageId != null &&
          s.recordingNote != null,
      orElse: () => Submission(
        assignmentId: widget.assignment.id,
        studentId: widget.student.id,
        type: QuestionType.drawing,
      ),
    );

    final isCompleted =
        currentSubmission.recordingNote != null &&
        currentSubmission.recordingNote!.isNotEmpty &&
        _parseDrawingMetadata(currentSubmission.recordingNote).length ==
            widget.assignment.questions.length;

    if (isCompleted) {
      return _buildCompletedView();
    }

    final questions = widget.assignment.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.assignment.title)),
        body: const Center(child: Text('No questions in this assignment')),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final isCurrentDrawingSubmitted = submittedDrawingIds.containsKey(
      currentQuestionIndex,
    );
    final totalDrawingsSubmitted = submittedDrawingIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.assignment.title),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drawing Assignment: ${widget.assignment.title}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: totalDrawingsSubmitted / questions.length,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progress: $totalDrawingsSubmitted/${questions.length} drawings completed',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${currentQuestionIndex + 1}: ${currentQuestion.text}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isCurrentDrawingSubmitted)
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'Drawing submitted (click canvas to re-edit)',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Draw below and click Submit Drawing',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Due: ${widget.assignment.dueDate.toLocal().toString().split(' ').first}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: DrawingCanvas(
              key: GlobalObjectKey(currentQuestionIndex),
              onImageGenerated: _onImageGenerated,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex > 0
                      ? _goToPreviousQuestion
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                if (totalDrawingsSubmitted == questions.length)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitEntireAssignment,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit All Drawings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  Expanded(child: Container()),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? _goToNextQuestion
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    final allSubmissions = FakeDb.submissions
        .where((s) => s.assignmentId == widget.assignment.id)
        .toList();

    return DefaultTabController(
      length: widget.assignment.questions.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.assignment.title),
          bottom: TabBar(
            isScrollable: true,
            tabs: List.generate(
              widget.assignment.questions.length,
              (index) => Tab(text: 'Q${index + 1}'),
            ),
          ),
        ),
        body: TabBarView(
          children: List.generate(
            widget.assignment.questions.length,
            (questionIndex) =>
                _buildQuestionSubmissionsView(allSubmissions, questionIndex),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSubmissionsView(
    List<Submission> allSubmissions,
    int questionIndex,
  ) {
    final question = widget.assignment.questions[questionIndex];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${questionIndex + 1}: ${question.text}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${allSubmissions.length} students submitted this question',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: allSubmissions.isEmpty
              ? const Center(child: Text('No submissions yet'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Submissions (Anonymous)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        // Grid showing all student submissions for this question
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: allSubmissions.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, submissionIndex) {
                            final submission = allSubmissions[submissionIndex];

                            // Get the drawing for this specific question
                            final drawingIds = _parseDrawingMetadata(
                              submission.recordingNote,
                            );
                            final drawingId = drawingIds[questionIndex];
                            final imageData = drawingId != null
                                ? FakeDb.drawingImages[drawingId]
                                : null;

                            return GestureDetector(
                              onTap: imageData != null
                                  ? () => _showImageFullscreen(imageData)
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: imageData != null
                                          ? Image.memory(
                                              imageData,
                                              fit: BoxFit.contain,
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      color: Colors.grey[100],
                                      width: double.infinity,
                                      child: Text(
                                        'Student ${submissionIndex + 1}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showImageFullscreen(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: InteractiveViewer(child: Image.memory(imageData))),
    );
  }
}
