import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class NoteStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes_data.json');
  }

  Future<List<Note>> readNotes() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      print("Error reading notes: $e");
      return [];
    }
  }

  Future<File> writeNotes(List<Note> notes) async {
    final file = await _localFile;
    final jsonList = notes.map((note) => note.toJson()).toList();
    return file.writeAsString(json.encode(jsonList));
  }
}