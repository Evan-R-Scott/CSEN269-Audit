import 'package:flutter/material.dart';

import '../../models.dart';
import 'parent_documents_screen.dart';

/// Screen for a parent to pick which child they want to view.
class ParentChildSelectionScreen extends StatefulWidget {
  final Parent parent;

  const ParentChildSelectionScreen({super.key, required this.parent});

  @override
  State<ParentChildSelectionScreen> createState() =>
      _ParentChildSelectionScreenState();
}

class _ParentChildSelectionScreenState
    extends State<ParentChildSelectionScreen> {
  Student? selectedStudent;

  void _continue() {
    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ParentDocumentsScreen(
          parent: widget.parent,
          selectedStudent: selectedStudent!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = FakeDb.students;
    return Scaffold(
      appBar: AppBar(title: const Text('Select Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${widget.parent.name}, choose which child you want to view:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (_, index) {
                  final s = students[index];
                  final isSelected = selectedStudent?.id == s.id;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blue : null,
                      ),
                      title: Text(s.name),
                      subtitle:
                          Text('Class: ${s.className} • ID: ${s.id}'),
                      onTap: () => setState(() => selectedStudent = s),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continue,
                child: const Text('Continue to Documents'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
