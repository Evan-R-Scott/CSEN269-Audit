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

/// Message in an assignment discussion thread.
class DiscussionMessage {
  String id;
  String assignmentId;
  String? studentId; // sender (student)
  String? teacherId; // sender (teacher)
  String text;
  DateTime createdAt;

  DiscussionMessage({
    required this.id,
    required this.assignmentId,
    this.studentId,
    this.teacherId,
    required this.text,
    required this.createdAt,
  });
}

/// Direct message between two users.
class DirectMessage {
  String id;
  String senderRole; // 'student' | 'teacher' | 'parent'
  String senderId;
  String recipientRole; // 'student' | 'teacher' | 'parent'
  String recipientId;
  String text;
  DateTime createdAt;

  DirectMessage({
    required this.id,
    required this.senderRole,
    required this.senderId,
    required this.recipientRole,
    required this.recipientId,
    required this.text,
    required this.createdAt,
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

  /// Days a student was absent (prototype data).
  static Map<String, List<DateTime>> absences = {
    'S01': [DateTime(2025, 1, 20)],
    'S02': [DateTime(2025, 1, 18), DateTime(2025, 1, 21)],
  };

  static String generateDrawingId() {
    return 'DRAW_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String generateDocumentId() {
    return 'DOC_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// In-memory discussion messages per assignment.
  static List<DiscussionMessage> discussionMessages = [];

  /// In-memory direct messages across users.
  static List<DirectMessage> directMessages = [];

  static DiscussionMessage addDiscussionMessage({
    required String assignmentId,
    String? studentId,
    String? teacherId,
    required String text,
  }) {
    final msg = DiscussionMessage(
      id: 'DISC_${DateTime.now().microsecondsSinceEpoch}',
      assignmentId: assignmentId,
      studentId: studentId,
      teacherId: teacherId,
      text: text,
      createdAt: DateTime.now(),
    );
    discussionMessages.add(msg);
    return msg;
  }

  static DirectMessage addDirectMessage({
    required String senderRole,
    required String senderId,
    required String recipientRole,
    required String recipientId,
    required String text,
  }) {
    final msg = DirectMessage(
      id: 'DM_${DateTime.now().microsecondsSinceEpoch}',
      senderRole: senderRole,
      senderId: senderId,
      recipientRole: recipientRole,
      recipientId: recipientId,
      text: text,
      createdAt: DateTime.now(),
    );
    directMessages.add(msg);
    return msg;
  }

  /// Assignments past due with no submission by this student.
  static List<Assignment> overdueAssignmentsFor(String studentId) {
    final now = DateTime.now();
    return assignments.where((a) {
      final hasSubmission = submissions.any(
        (s) => s.assignmentId == a.id && s.studentId == studentId,
      );
      return a.dueDate.isBefore(now) && !hasSubmission;
    }).toList();
  }

  /// Absent dates for a student (if any).
  static List<DateTime> absencesFor(String studentId) {
    return absences[studentId] ?? [];
  }

  /// Simple per-student score timeline, newest last.
  static List<Map<String, dynamic>> scoreTimeline(String studentId) {
    final graded = submissions
        .where((s) => s.studentId == studentId && s.score != null)
        .toList();
    graded.sort((a, b) => a.submittedAt != null && b.submittedAt != null
        ? a.submittedAt!.compareTo(b.submittedAt!)
        : 0);

    return graded.map((s) {
      final assignment =
          assignments.firstWhere((a) => a.id == s.assignmentId, orElse: () {
        return Assignment(
          id: s.assignmentId,
          title: 'Assignment',
          text: '',
          postedDate: DateTime.now(),
          dueDate: DateTime.now(),
          type: s.type,
          questions: const [],
        );
      });
      return {
        'title': assignment.title,
        'score': s.score!,
      };
    }).toList();
  }

  /// Very light subject insight based on question type trends.
  static String subjectInsight(String studentId) {
    int mcqTotal = 0;
    int mcqCount = 0;
    int drawingTotal = 0;
    int drawingCount = 0;

    for (final sub in submissions.where(
      (s) => s.studentId == studentId && s.score != null,
    )) {
      if (sub.type == QuestionType.mcq) {
        mcqTotal += sub.score!;
        mcqCount++;
      } else if (sub.type == QuestionType.drawing) {
        drawingTotal += sub.score!;
        drawingCount++;
      }
    }

    final mcqAvg = mcqCount > 0 ? mcqTotal / mcqCount : null;
    final artAvg = drawingCount > 0 ? drawingTotal / drawingCount : null;

    if (mcqAvg != null && artAvg != null) {
      if (mcqAvg < artAvg - 10) {
        return 'Needs more practice in math, but excellent in art.';
      } else if (artAvg < mcqAvg - 10) {
        return 'Art needs support, math performance is strong.';
      }
    }
    return 'Balanced performance — keep up steady practice across subjects.';
  }

  /// Get a student's numeric score for an assignment (if graded).
  static int? getStudentScore(String assignmentId, String studentId) {
    final s = submissions.firstWhere(
      (sub) => sub.assignmentId == assignmentId && sub.studentId == studentId,
      orElse: () => Submission(
        assignmentId: assignmentId,
        studentId: studentId,
        type: QuestionType.mcq,
      ),
    );
    return s.score;
  }

  /// Compute ranks (1-based) for a graded assignment: higher scores rank first.
  static Map<String, int> computeRanks(String assignmentId) {
    final graded = submissions
        .where(
          (s) =>
              s.assignmentId == assignmentId &&
              s.score != null,
        )
        .toList();
    graded.sort((a, b) => b.score!.compareTo(a.score!));
    final ranks = <String, int>{};
    for (var i = 0; i < graded.length; i++) {
      ranks[graded[i].studentId] = i + 1;
    }
    return ranks;
  }

  /// Convert a numeric score to a simple letter grade.
  static String? letterGrade(int? score) {
    if (score == null) return null;
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  /// Generate a short parent-facing note based on average score.
  static String parentNoteFromAverage(double avgScore) {
    if (avgScore >= 90) {
      return 'Great work! Keep encouraging them to maintain this momentum.';
    } else if (avgScore >= 80) {
      return 'Solid performance. A bit more practice can push them to the top.';
    } else if (avgScore >= 70) {
      return 'Doing okay. Targeted review of missed topics could help.';
    } else if (avgScore >= 60) {
      return 'Needs some support. Consider short daily practice sessions.';
    } else {
      return 'Let’s partner up—check assignments together and ask the teacher for help.';
    }
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
