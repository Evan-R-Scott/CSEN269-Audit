import 'package:flutter/material.dart';

/// --------------------------------------------
/// ENUMS
/// --------------------------------------------

/// Represents different question types.
enum QuestionType {
  mcq,
  recording,
}

/// --------------------------------------------
/// DATA MODELS
/// --------------------------------------------

/// Model for a teacher account.
class Teacher {
  String username;
  String password;

  Teacher({
    required this.username,
    required this.password,
  });
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
  int? score;
  String? comment;

  Submission({
    required this.assignmentId,
    required this.studentId,
    required this.type,
    this.mcqAnswers,
    this.recordingNote,
    this.score,
    this.comment,
  });
}

/// --------------------------------------------
/// FAKE DATABASE (for prototype)
/// --------------------------------------------

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
}

/// --------------------------------------------
/// EXTENSIONS & UTILITIES
/// --------------------------------------------

/// Helper to easily find the first match or null.
extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
