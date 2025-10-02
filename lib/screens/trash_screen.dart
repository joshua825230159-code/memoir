import 'package:flutter/material.dart';
import '../models/note.dart';

class TrashScreen extends StatefulWidget {
  final List<Note> deletedNotes;

  const TrashScreen({super.key, required this.deletedNotes});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late List<Note> _notesInTrash;
  final Set<Note> _selectedNotes = {};

  @override
  void initState() {
    super.initState();
    _notesInTrash = List.from(widget.deletedNotes);
  }

  void _toggleSelection(Note note) {
    setState(() {
      if (_selectedNotes.contains(note)) {
        _selectedNotes.remove(note);
      } else {
        _selectedNotes.add(note);
      }
    });
  }

  void _restoreSelectedNotes() {
    if (_selectedNotes.isNotEmpty) {
      Navigator.pop(context, {'restored': _selectedNotes.toList()});
    }
  }

  void _emptyTrash() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Sampah?'),
        content: Text('Semua ${_notesInTrash.length} catatan dalam sampah akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'emptied': true});
            },
            child: Text('Hapus', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sampah'),
        actions: [
          if (_notesInTrash.isNotEmpty && _selectedNotes.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _emptyTrash,
              tooltip: 'Kosongkan Sampah',
            ),
          if (_selectedNotes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore_from_trash),
              onPressed: _restoreSelectedNotes,
              tooltip: 'Pulihkan',
            ),
        ],
      ),
      body: _notesInTrash.isEmpty
          ? const Center(
              child: Text('Tidak ada catatan di sampah.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notesInTrash.length,
              itemBuilder: (context, index) {
                final note = _notesInTrash[index];
                final isSelected = _selectedNotes.contains(note);
                return Card(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
                  child: ListTile(
                    onTap: () => _toggleSelection(note),
                    title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                        : const Icon(Icons.radio_button_unchecked),
                  ),
                );
              },
            ),
    );
  }
}
