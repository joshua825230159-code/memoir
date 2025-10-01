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
  
  Set<String> _currentTags = {}; 

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _currentTags = Set.from(widget.note!.tags); 
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
        tags: _currentTags, 
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
  
  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = '';
        return AlertDialog(
          title: Text('Kelola Tag'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display current tags
                  Wrap(
                    spacing: 8.0,
                    children: _currentTags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        // Use setState of the main screen to update the note's tags
                        setState(() { 
                          _currentTags.remove(tag);
                        });
                        // Use setStateDialog to update the dialog's appearance
                        setStateDialog(() {}); 
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                  // Input field for new tag
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'Masukkan tag baru'),
                    onChanged: (value) => newTag = value.trim().toLowerCase(),
                    onSubmitted: (value) {
                      if (newTag.isNotEmpty && !_currentTags.contains(newTag)) {
                        setState(() {
                          _currentTags.add(newTag);
                        });
                        Navigator.pop(context); // Close the dialog
                      }
                    },
                  ),
                ],
              );
            }
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                if (newTag.isNotEmpty && !_currentTags.contains(newTag)) {
                    setState(() {
                      _currentTags.add(newTag);
                    });
                }
                Navigator.pop(context);
              },
              child: Text('Tambahkan'),
            ),
          ],
        );
      },
    );
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
                    IconButton(
                        icon: Icon(Icons.label_outline), 
                        onPressed: _showTagDialog
                    ), 
                    IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
                    IconButton(
                        icon: Icon(Icons.delete_outline), // Ikon diubah menjadi tempat sampah
                        onPressed: _deleteNote
                    ),
                  ],
                ),
              ),
              
              if (_currentTags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 0,
                    children: _currentTags.map((tag) => Chip(
                      label: Text('#$tag', style: TextStyle(fontSize: 12)),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    )).toList(),
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
