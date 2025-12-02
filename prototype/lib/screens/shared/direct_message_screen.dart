import 'package:flutter/material.dart';

import '../../models.dart';

/// Direct messaging screen for any role.
class DirectMessageScreen extends StatefulWidget {
  final Student? student;
  final Teacher? teacher;
  final Parent? parent;

  const DirectMessageScreen({super.key, this.student, this.teacher, this.parent});

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  String? _recipientRole; // student/teacher/parent
  String? _recipientId;
  final TextEditingController _controller = TextEditingController();

  String get _senderRole {
    if (widget.student != null) return 'student';
    if (widget.teacher != null) return 'teacher';
    return 'parent';
  }

  String get _senderId {
    if (widget.student != null) return widget.student!.id;
    if (widget.teacher != null) return widget.teacher!.username;
    return widget.parent!.id;
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _recipientRole == null || _recipientId == null) return;
    FakeDb.addDirectMessage(
      senderRole: _senderRole,
      senderId: _senderId,
      recipientRole: _recipientRole!,
      recipientId: _recipientId!,
      text: text,
    );
    _controller.clear();
    setState(() {});
  }

  List<DirectMessage> _messagesBetween() {
    if (_recipientRole == null || _recipientId == null) return [];
    return FakeDb.directMessages
        .where((m) =>
            (m.senderRole == _senderRole &&
                m.senderId == _senderId &&
                m.recipientRole == _recipientRole &&
                m.recipientId == _recipientId) ||
            (m.recipientRole == _senderRole &&
                m.recipientId == _senderId &&
                m.senderRole == _recipientRole &&
                m.senderId == _recipientId))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  String _nameFor(String role, String id) {
    if (role == 'student') {
      final s = FakeDb.students.firstWhere(
        (st) => st.id == id,
        orElse: () => Student(id: id, name: 'Student', className: ''),
      );
      return s.name;
    }
    if (role == 'teacher') {
      final t = FakeDb.teachers.firstWhere(
        (tc) => tc.username == id,
        orElse: () => Teacher(username: id, password: ''),
      );
      return 'Teacher ${t.username}';
    }
    final p = FakeDb.parents.firstWhere(
      (pr) => pr.id == id,
      orElse: () => Parent(id: id, name: 'Parent', email: '', password: ''),
    );
    return p.name;
  }

  List<DropdownMenuItem<String>> _recipientOptions(String role) {
    if (role == 'student') {
      return FakeDb.students
          .map((s) => DropdownMenuItem(
                value: s.id,
                child: Text('${s.name} (${s.id})'),
              ))
          .toList();
    }
    if (role == 'teacher') {
      return FakeDb.teachers
          .map((t) => DropdownMenuItem(
                value: t.username,
                child: Text('Teacher ${t.username}'),
              ))
          .toList();
    }
    return FakeDb.parents
        .map((p) => DropdownMenuItem(
              value: p.id,
              child: Text('${p.name} (${p.email})'),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messagesBetween();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Recipient role',
                      border: OutlineInputBorder(),
                    ),
                    value: _recipientRole,
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Student')),
                      DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'parent', child: Text('Parent')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _recipientRole = val;
                        _recipientId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select user',
                      border: OutlineInputBorder(),
                    ),
                    value: _recipientId,
                    items: _recipientRole == null
                        ? const []
                        : _recipientOptions(_recipientRole!),
                    onChanged: (val) => setState(() => _recipientId = val),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Start a conversation.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isMe = msg.senderRole == _senderRole &&
                          msg.senderId == _senderId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.green[50]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameFor(msg.senderRole, msg.senderId),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(msg.text),
                              const SizedBox(height: 4),
                              Text(
                                msg.createdAt
                                    .toLocal()
                                    .toString()
                                    .split('.')
                                    .first,
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
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
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
