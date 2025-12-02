import 'package:flutter/material.dart';

import '../../models.dart';

/// Shared discussion screen for an assignment (students and teachers).
class AssignmentDiscussionScreen extends StatefulWidget {
  final Assignment assignment;
  final Student? student;
  final Teacher? teacher;

  const AssignmentDiscussionScreen({
    super.key,
    required this.assignment,
    this.student,
    this.teacher,
  });

  @override
  State<AssignmentDiscussionScreen> createState() =>
      _AssignmentDiscussionScreenState();
}

class _AssignmentDiscussionScreenState extends State<AssignmentDiscussionScreen> {
  final TextEditingController _controller = TextEditingController();

  void _postMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FakeDb.addDiscussionMessage(
      assignmentId: widget.assignment.id,
      studentId: widget.student?.id,
      teacherId: widget.teacher?.username,
      text: text,
    );
    _controller.clear();
    setState(() {});
  }

  String _senderName(DiscussionMessage msg) {
    if (msg.teacherId != null) {
      return 'Teacher ${msg.teacherId}';
    }
    if (msg.studentId != null) {
      final st = FakeDb.students.firstWhere(
        (s) => s.id == msg.studentId,
        orElse: () => Student(id: msg.studentId!, name: 'Student', className: ''),
      );
      return st.name;
    }
    return 'Unknown';
  }

  bool _isOwnMessage(DiscussionMessage msg) {
    if (widget.student != null) {
      return msg.studentId == widget.student!.id;
    }
    if (widget.teacher != null) {
      return msg.teacherId == widget.teacher!.username;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final messages = FakeDb.discussionMessages
        .where((m) => m.assignmentId == widget.assignment.id)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion: ${widget.assignment.title}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isMe = _isOwnMessage(msg);
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue[50]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _senderName(msg),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(msg.text),
                              const SizedBox(height: 4),
                              Text(
                                msg.createdAt.toLocal().toString().split('.').first,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask a question or share an idea...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _postMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
