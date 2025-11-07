import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Student App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
