import 'package:flutter/material.dart';
import '../../models.dart';
import 'student_mcq_assignment_screen.dart';
import 'student_recording_assignment_screen.dart';

/// Student tab: list of assignments + open them for answering.
class StudentAssignmentsTab extends StatefulWidget {
  final Student student;

  const StudentAssignmentsTab({super.key, required this.student});

  @override
  State<StudentAssignmentsTab> createState() => _StudentAssignmentsTabState();
}

class _StudentAssignmentsTabState extends State<StudentAssignmentsTab> {
  void _openAssignment(Assignment a) {
    if (a.type == QuestionType.mcq) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentMcqAssignmentScreen(
            assignment: a,
            student: widget.student,
          ),
        ),
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentRecordingAssignmentScreen(
            assignment: a,
            student: widget.student,
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignments = FakeDb.assignments;

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (_, index) {
        final a = assignments[index];
        final submission = FakeDb.submissions.firstWhere(
          (s) =>
              s.assignmentId == a.id &&
              s.studentId == widget.student.id,
          orElse: () => Submission(
            assignmentId: a.id,
            studentId: widget.student.id,
            type: a.type,
          ),
        );

        final isSubmitted = submission.score != null ||
            (submission.mcqAnswers != null &&
                submission.mcqAnswers!.isNotEmpty) ||
            (submission.recordingNote != null &&
                submission.recordingNote!.isNotEmpty);

        final status = isSubmitted ? 'Submitted' : 'Not submitted';

        return Card(
          child: ListTile(
            leading: Icon(
              isSubmitted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSubmitted ? Colors.green : null,
            ),
            title: Text(a.title),
            subtitle: Text(
              'Posted: ${a.postedDate.toLocal().toString().split(' ').first} • '
              'Due: ${a.dueDate.toLocal().toString().split(' ').first} • '
              'Status: $status',
            ),
            onTap: () => _openAssignment(a),
          ),
        );
      },
    );
  }
}
