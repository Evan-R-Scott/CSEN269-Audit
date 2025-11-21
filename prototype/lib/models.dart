import 'package:flutter/material.dart';
import 'dart:typed_data';

/// Represents different question types.
enum QuestionType { mcq, recording, drawing }

/// Model for a teacher account.
class Teacher {
  String username;
  String password;

  Teacher({required this.username, required this.password});
}

/// Model for a student.
class Student {
  String id;
  String name;
  String className;
  String password;

  Student({
    required this.id,
    required this.name,
    required this.className,
    this.password = 'homelga',
  });
}

/// Model for an assignment.
class Assignment {
  String id;
  String title;
  String text;
  DateTime postedDate;
  DateTime dueDate;
  QuestionType type;
  List<Question> questions;

  Assignment({
    required this.id,
    required this.title,
    required this.text,
    required this.postedDate,
    required this.dueDate,
    required this.type,
    required this.questions,
  });
}

/// Model for an individual question.
class Question {
  String id;
  String text;
  QuestionType type;
  List<String>? options;
  int? correctIndex;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.correctIndex,
  });
}

/// Model for a student's submission.
class Submission {
  String assignmentId;
  String studentId;
  QuestionType type;
  List<int>? mcqAnswers;
  String? recordingNote;
  String? drawingImageId;
  int? score;
  String? comment;
  DateTime? submittedAt;

  Submission({
    required this.assignmentId,
    required this.studentId,
    required this.type,
    this.mcqAnswers,
    this.recordingNote,
    this.drawingImageId,
    this.score,
    this.comment,
    this.submittedAt,
  });
}

/// Model for a document that parents can access
class Document {
  String id;
  String title;
  String description;
  String fileName;
  DateTime uploadedDate;
  String uploadedBy;

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.uploadedDate,
    required this.uploadedBy,
  });
}

/// Model for a parent account
class Parent {
  String id;
  String name;
  String email;
  String password;

  Parent({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}

/// FAKE DATABASE (for prototype)
class FakeDb {
  static List<Teacher> teachers = [
    Teacher(username: 'teacher1', password: '1234'),
  ];

  static List<Student> students = [
    Student(id: 'S01', name: 'Alice', className: 'Class 1'),
    Student(id: 'S02', name: 'Bob', className: 'Class 1'),
    Student(id: 'S03', name: 'Charlie', className: 'Class 2'),
  ];

  static List<Assignment> assignments = [];

  static List<Submission> submissions = [];

  static Map<String, Uint8List> drawingImages = {};

  static List<Document> documents = [
    Document(
      id: 'DOC_001',
      title: 'School Calendar 2025',
      description: 'Annual school calendar with all important dates',
      fileName: 'school_calendar_2025.pdf',
      uploadedDate: DateTime(2025, 1, 15),
      uploadedBy: 'teacher1',
    ),
    Document(
      id: 'DOC_002',
      title: 'Parent Handbook',
      description: 'Complete guide for parents about school policies',
      fileName: 'parent_handbook.pdf',
      uploadedDate: DateTime(2025, 1, 10),
      uploadedBy: 'teacher1',
    ),
  ];

  static List<Parent> parents = [
    Parent(
      id: 'P001',
      name: 'Test User',
      email: 'user@example.com',
      password: 'parent123',
    ),
    Parent(
      id: 'P002',
      name: 'Test User2',
      email: 'user2@example.com',
      password: 'parent123',
    ),
  ];

  static String generateDrawingId() {
    return 'DRAW_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String generateDocumentId() {
    return 'DOC_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// EXTENSIONS & UTILITIES
extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
