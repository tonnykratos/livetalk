import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/live_manager.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LiveTalkApp());
}

class LiveTalkApp extends StatelessWidget {
  const LiveTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LiveManager(),
      child: MaterialApp(
        title: 'LiveTalk',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
