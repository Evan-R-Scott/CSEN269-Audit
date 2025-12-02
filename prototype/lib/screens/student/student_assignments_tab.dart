import 'package:flutter/material.dart';
import '../../models.dart';
import 'student_mcq_assignment_screen.dart';
import 'student_recording_assignment_screen.dart';
import 'student_drawing_assignment_screen.dart';
import '../shared/assignment_discussion_screen.dart';

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
    } else if (a.type == QuestionType.recording) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentRecordingAssignmentScreen(
            assignment: a,
            student: widget.student,
          ),
        ),
      ).then((_) => setState(() {}));
    } else if (a.type == QuestionType.drawing) {
      // ADD THIS BLOCK
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDrawingAssignmentScreen(
            assignment: a,
            student: widget.student,
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  void _openDiscussion(Assignment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDiscussionScreen(
          assignment: a,
          student: widget.student,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final assignments = FakeDb.assignments;

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (_, index) {
        final a = assignments[index];
        final submission = FakeDb.submissions.firstWhere(
          (s) => s.assignmentId == a.id && s.studentId == widget.student.id,
          orElse: () => Submission(
            assignmentId: a.id,
            studentId: widget.student.id,
            type: a.type,
          ),
        );

        final ranks = FakeDb.computeRanks(a.id);
        final rank = ranks[widget.student.id];
        final totalRanked = ranks.length;
        final score = submission.score;
        final grade = FakeDb.letterGrade(score);

        final isSubmitted =
            submission.score != null ||
            (submission.mcqAnswers != null &&
                submission.mcqAnswers!.isNotEmpty) ||
            (submission.recordingNote != null &&
                submission.recordingNote!.isNotEmpty) ||
            (submission.drawingImageId != null &&
                submission.drawingImageId!.isNotEmpty);

        final status = isSubmitted ? 'Submitted' : 'Not submitted';
        final scoreText = score != null
            ? 'Score: $score${grade != null ? ' ($grade)' : ''}'
            : null;
        final rankText = rank != null && totalRanked > 0
            ? 'Rank: $rank/$totalRanked'
            : null;
        final details = [
          'Posted: ${a.postedDate.toLocal().toString().split(' ').first}',
          'Due: ${a.dueDate.toLocal().toString().split(' ').first}',
          'Status: $status',
          if (scoreText != null) scoreText,
          if (rankText != null) rankText,
        ].join(' • ');

        return Card(
          child: ListTile(
            leading: Icon(
              isSubmitted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSubmitted ? Colors.green : null,
            ),
            title: Text(a.title),
            subtitle: Text(details),
            trailing: IconButton(
              icon: const Icon(Icons.forum),
              tooltip: 'Discussion',
              onPressed: () => _openDiscussion(a),
            ),
            onTap: () => _openAssignment(a),
          ),
        );
      },
    );
  }
}
