import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  NoteEditScreen({this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    } else {
      _titleController.text = 'Judul';
    }
  }

  Future<bool> _onWillPop() async {
    if (_contentController.text.isNotEmpty || _titleController.text != 'Judul') {
      final noteToSave = Note(
        title: _titleController.text.isEmpty ? 'Tanpa Judul' : _titleController.text,
        content: _contentController.text,
        timestamp: DateTime.now(),
      );
      Navigator.pop(context, noteToSave);
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  void _deleteNote() {
    Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // -- CUSTOM APP BAR --
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new),
                      onPressed: () => _onWillPop(),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Judul',
                        ),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
                    IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
                    // -- PERUBAHAN DI SINI --
                    IconButton(
                        icon: Icon(Icons.delete_outline), // Ikon diubah menjadi tempat sampah
                        onPressed: _deleteNote
                    ),
                  ],
                ),
              ),

              // -- AREA KONTEN CATATAN --
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Mulai menulis...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}