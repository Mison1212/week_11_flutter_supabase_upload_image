import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';

const supabaseUrl = 'https://pvqmvpxhculwuntcvkvh.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2cW12cHhoY3Vsd3VudGN2a3ZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzMTA3MTksImV4cCI6MjA4MDg4NjcxOX0.nl8By8yFcUWxh0K8GLSyG2N8g53YQTD5eZYIXddOvHM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'supabase foto',
      home: MyHomePage(),
    );
  }
}