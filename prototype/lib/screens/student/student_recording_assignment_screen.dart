import 'package:flutter/material.dart';
import '../../models.dart';

/// Student answering Recording assignments (UI only, no real audio).
class StudentRecordingAssignmentScreen extends StatefulWidget {
  final Assignment assignment;
  final Student student;

  const StudentRecordingAssignmentScreen({
    super.key,
    required this.assignment,
    required this.student,
  });

  @override
  State<StudentRecordingAssignmentScreen> createState() =>
      _StudentRecordingAssignmentScreenState();
}

class _StudentRecordingAssignmentScreenState
    extends State<StudentRecordingAssignmentScreen> {
  bool isRecording = false;
  String note = '';

  void _toggleRecord() {
    setState(() {
      isRecording = !isRecording;
    });
  }

  void _submit() {
    if (note.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please record or write something before uploading.'),
        ),
      );
      return;
    }

    // Remove previous submission if any.
    FakeDb.submissions.removeWhere(
      (s) =>
          s.assignmentId == widget.assignment.id &&
          s.studentId == widget.student.id,
    );

    FakeDb.submissions.add(
      Submission(
        assignmentId: widget.assignment.id,
        studentId: widget.student.id,
        type: QuestionType.recording,
        recordingNote: note.trim(),
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recording Submitted'),
        content: const Text(
          'Your recording was uploaded (simulated in this prototype).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to assignments list
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
    final q = a.questions.isNotEmpty ? a.questions.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(a.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (q != null)
              Text(
                q.text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.filled(
                  onPressed: _toggleRecord,
                  icon: Icon(
                    isRecording ? Icons.mic_off : Icons.mic,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isRecording ? 'Recording...' : 'Tap mic to simulate recording',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Recording note (placeholder instead of real audio):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe what you said in your recording...',
              ),
              onChanged: (val) => note = val,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
