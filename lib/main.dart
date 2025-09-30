import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart'; // import provider
import 'utils/app_themes.dart';        // import tema
import 'screens/note_list_screen.dart';

void main() {
  runApp(
    // Bungkus aplikasi dengan ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Panggil provider untuk mendapatkan status tema saat ini
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Aplikasi Catatan',
      // Hapus definisi tema di sini dan ganti dengan properti di bawah
      theme: AppThemes.lightTheme,     // Atur tema terang
      darkTheme: AppThemes.darkTheme,  // Atur tema gelap
      themeMode: themeProvider.themeMode, // Biarkan provider yang menentukan mode
      home: NoteListScreen(),
    );
  }
}