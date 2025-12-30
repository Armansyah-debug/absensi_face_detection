import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

void main() async {
  // 1. Wajib untuk memastikan binding native sudah siap
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Tambahkan DefaultFirebaseOptions agar lebih stabil di 2025
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Wajah',
      theme: ThemeData(
        useMaterial3: true, // Standar Flutter 2025
        colorSchemeSeed: const Color(0xFF4682B4),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
