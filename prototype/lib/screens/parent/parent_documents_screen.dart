import 'package:flutter/material.dart';
import '../../models.dart';
import '../shared/direct_message_screen.dart';

/// Parent view: access documents
class ParentDocumentsScreen extends StatefulWidget {
  final Parent parent;
  final Student? selectedStudent;

  const ParentDocumentsScreen({
    super.key,
    required this.parent,
    this.selectedStudent,
  });

  @override
  State<ParentDocumentsScreen> createState() => _ParentDocumentsScreenState();
}

class _ParentDocumentsScreenState extends State<ParentDocumentsScreen> {
  void _logout() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final documents = FakeDb.documents;
    final student = widget.selectedStudent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          student != null
              ? 'School Documents - ${student.name}'
              : 'School Documents',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DirectMessageScreen(parent: widget.parent),
                ),
              );
            },
            icon: const Icon(Icons.mail),
            tooltip: 'Messages',
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: documents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No documents available'),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (student != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.child_care, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Viewing documents for: ${student.name} (${student.className})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (student != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _buildParentInsight(student),
                  ),
                if (student != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _buildAlerts(student),
                  ),
                if (student != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _buildProgress(student),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: documents.length,
                    itemBuilder: (_, index) {
                      final doc = documents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red[600],
                            size: 32,
                          ),
                          title: Text(
                            doc.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                doc.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Uploaded: ${doc.uploadedDate.toLocal().toString().split(' ').first}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () {
                              _openDocument(doc);
                            },
                          ),
                          onTap: () {
                            _openDocument(doc);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _openDocument(Document doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: doc)),
    );
  }

  Widget _buildParentInsight(Student student) {
    final graded = FakeDb.submissions
        .where(
          (s) => s.studentId == student.id && s.score != null,
        )
        .toList();

    if (graded.isEmpty) {
      return Card(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No graded assignments yet for ${student.name}.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final avgScore = graded
            .map((s) => s.score!)
            .reduce((a, b) => a + b) /
        graded.length;
    final avgGrade = FakeDb.letterGrade(avgScore.round());

    final latest = graded.last;
    final latestAssignment = FakeDb.assignments.firstWhere(
      (a) => a.id == latest.assignmentId,
      orElse: () => Assignment(
        id: latest.assignmentId,
        title: 'Recent assignment',
        text: '',
        postedDate: DateTime.now(),
        dueDate: DateTime.now(),
        type: latest.type,
        questions: const [],
      ),
    );
    final latestGrade = FakeDb.letterGrade(latest.score);
    final note = FakeDb.parentNoteFromAverage(avgScore);

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stacked_line_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Progress snapshot',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Average score: ${avgScore.toStringAsFixed(1)}'
              '${avgGrade != null ? ' ($avgGrade)' : ''}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Latest: ${latestAssignment.title} — '
              '${latest.score} ${latestGrade != null ? "($latestGrade)" : ""}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              note,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(Student student) {
    final overdue = FakeDb.overdueAssignmentsFor(student.id);
    final absences = FakeDb.absencesFor(student.id);

    if (overdue.isEmpty && absences.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Important alerts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (absences.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'Absent on ${absences.last.toLocal().toString().split(' ').first}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            if (overdue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'Missing assignments past due: ${overdue.map((a) => a.title).join(", ")}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(Student student) {
    final timeline = FakeDb.scoreTimeline(student.id);
    final insight = FakeDb.subjectInsight(student.id);

    if (timeline.isEmpty) {
      return Card(
        color: Colors.grey[100],
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'No scores yet to chart.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      );
    }

    return Card(
      color: Colors.blueGrey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.show_chart, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  'Progress',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: _ScoreSparkline(timeline: timeline),
            ),
            const SizedBox(height: 8),
            Text(
              insight,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full screen document viewer
class DocumentViewerScreen extends StatelessWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloaded: ${document.fileName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 48,
                        color: Colors.red[600],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.fileName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PDF Document',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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
            // Document details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    document.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Document Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('File Name', document.fileName),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Uploaded Date',
                          document.uploadedDate
                              .toLocal()
                              .toString()
                              .split(' ')
                              .first,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Uploaded By', document.uploadedBy),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // PDF Preview (simulated)
                  Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${document.fileName}\n(PDF Preview)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloaded: ${document.fileName}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Document'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Simple sparkline chart for parent view.
class _ScoreSparkline extends StatelessWidget {
  final List<Map<String, dynamic>> timeline;

  const _ScoreSparkline({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(timeline),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<Map<String, dynamic>> timeline;

  _SparklinePainter(this.timeline);

  @override
  void paint(Canvas canvas, Size size) {
    if (timeline.isEmpty) return;

    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    const maxScore = 100.0;
    const minScore = 0.0;
    final count = timeline.length;
    final double dx = count > 1 ? size.width / (count - 1) : 0.0;

    final path = Path();
    for (var i = 0; i < count; i++) {
      final score = timeline[i]['score'] as num;
      final normalized = ((score - minScore) / (maxScore - minScore))
          .clamp(0.0, 1.0)
          .toDouble();
      final double x = dx * i;
      final double y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, paintPoint);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
