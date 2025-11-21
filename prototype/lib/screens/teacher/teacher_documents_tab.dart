import 'package:flutter/material.dart';
import '../../models.dart';

/// Teacher tab: manage documents for parents
class TeacherDocumentsTab extends StatefulWidget {
  final Teacher teacher;
  final VoidCallback onChanged;

  const TeacherDocumentsTab({
    super.key,
    required this.teacher,
    required this.onChanged,
  });

  @override
  State<TeacherDocumentsTab> createState() => _TeacherDocumentsTabState();
}

class _TeacherDocumentsTabState extends State<TeacherDocumentsTab> {
  void _addDocument() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final fileController = TextEditingController();

    final newDoc = await showDialog<Document>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upload Document'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Document Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fileController,
                decoration: const InputDecoration(
                  labelText: 'File Name (e.g., document.pdf)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Note: In a real app, you would select an actual file. For now, just enter the filename.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  fileController.text.trim().isEmpty) {
                return;
              }
              final doc = Document(
                id: FakeDb.generateDocumentId(),
                title: titleController.text.trim(),
                description: descController.text.trim(),
                fileName: fileController.text.trim(),
                uploadedDate: DateTime.now(),
                uploadedBy: widget.teacher.username,
              );
              Navigator.pop(context, doc);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (newDoc != null) {
      setState(() {
        FakeDb.documents.add(newDoc);
      });
      widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
    }
  }

  void _deleteDocument(Document doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                FakeDb.documents.removeWhere((d) => d.id == doc.id);
              });
              widget.onChanged();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Document deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = FakeDb.documents;

    return Scaffold(
      body: documents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No documents uploaded yet'),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to upload your first document',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${doc.fileName} • ${doc.uploadedDate.toLocal().toString().split(' ').first}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDocument(doc),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDocument,
        label: const Text('Upload Document'),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }
}
