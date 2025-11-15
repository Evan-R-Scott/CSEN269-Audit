import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../models.dart';
import '../widgets/drawing_canvas_widget.dart';

/// Student answering drawing assignments.
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
  Uint8List? generatedImage;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    // Check if already submitted
    isSubmitted = FakeDb.submissions.any(
      (s) =>
          s.assignmentId == widget.assignment.id &&
          s.studentId == widget.student.id &&
          s.drawingImageId != null,
    );
  }

  void _onImageGenerated(Uint8List imageData) {
    setState(() {
      generatedImage = imageData;
    });

    // Show dialog to confirm submission
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
              _submitDrawing(imageData);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitDrawing(Uint8List imageData) {
    // Generate drawing ID
    final drawingId = FakeDb.generateDrawingId();

    // Store the image
    FakeDb.drawingImages[drawingId] = imageData;

    // Remove old submission if exists
    FakeDb.submissions.removeWhere(
      (s) =>
          s.assignmentId == widget.assignment.id &&
          s.studentId == widget.student.id,
    );

    // Add new submission
    FakeDb.submissions.add(
      Submission(
        assignmentId: widget.assignment.id,
        studentId: widget.student.id,
        type: QuestionType.drawing,
        drawingImageId: drawingId,
        submittedAt: DateTime.now(),
      ),
    );

    setState(() {
      isSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Drawing submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.assignment.questions.isNotEmpty
        ? widget.assignment.questions.first
        : null;

    if (isSubmitted) {
      // Show submissions gallery
      return _buildGalleryView(q);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.assignment.title)),
      body: Column(
        children: [
          // Assignment prompt
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assignment: ${widget.assignment.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (q != null)
                  Text(
                    'Prompt: ${q.text}',
                    style: const TextStyle(fontSize: 14),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Due: ${widget.assignment.dueDate.toLocal().toString().split(' ').first}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Drawing canvas
          Expanded(child: DrawingCanvas(onImageGenerated: _onImageGenerated)),
        ],
      ),
    );
  }

  Widget _buildGalleryView(Question? q) {
    final allSubmissions = FakeDb.submissions
        .where((s) => s.assignmentId == widget.assignment.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.assignment.title)),
      body: Column(
        children: [
          // Assignment prompt
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Submitted!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (q != null)
                  Text(
                    'Prompt: ${q.text}',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
          // Gallery of submissions
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
                            'Student Submissions (Anonymous)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
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
                            itemBuilder: (context, index) {
                              final submission = allSubmissions[index];
                              final imageData =
                                  submission.drawingImageId != null
                                  ? FakeDb.drawingImages[submission
                                        .drawingImageId]
                                  : null;

                              return GestureDetector(
                                onTap: imageData != null
                                    ? () => _showImageFullscreen(imageData)
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
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
                                                  child: Text('No image'),
                                                ),
                                              ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.grey[100],
                                        width: double.infinity,
                                        child: Text(
                                          'Submission ${index + 1}',
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
      ),
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
