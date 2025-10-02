import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/tag_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
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
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_contentController.text.isNotEmpty || _titleController.text.isNotEmpty) {
      final noteToSave = Note(
        title: _titleController.text.isEmpty ? 'Tanpa Judul' : _titleController.text,
        content: _contentController.text,
        timestamp: DateTime.now(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        tags: _currentTags,
      );

      // simpan tag ke global provider
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      for (var tag in _currentTags) {
        tagProvider.addTag(tag);
      }

      Navigator.pop(context, noteToSave);
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  void _deleteNote() {
    if (widget.note != null) {
      Navigator.pop(context, 'deleted');
    } else {
      Navigator.pop(context);
    }
  }

  void _showTagBottomSheet() {
    final tagInputController = TextEditingController();
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            final tagProvider = Provider.of<TagProvider>(context, listen: false);
            final allTags = tagProvider.allTags;

            void addTag(String newTag) {
              if (newTag.isNotEmpty && !_currentTags.contains(newTag)) {
                setState(() {
                  _currentTags.add(newTag);
                });
                setStateBottomSheet(() {});
                tagInputController.clear();
                focusNode.requestFocus();
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tambah tag', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_currentTags.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('Belum ada tag.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentTags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _currentTags.remove(tag);
                          });
                          setStateBottomSheet(() {});
                        },
                      )).toList(),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allTags.map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          if (!_currentTags.contains(tag)) {
                            setState(() {
                              _currentTags.add(tag);
                            });
                            setStateBottomSheet(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagInputController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: '# Buat tag baru',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => addTag(tagInputController.text.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: _onWillPop),
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Judul'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.label_outline), onPressed: _showTagBottomSheet),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteNote),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(hintText: 'Mulai menulis...', border: InputBorder.none),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    autofocus: widget.note == null,
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
