import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // FIX 1: Menambahkan import yang kurang
import '../models/note.dart';
import '../providers/theme_provider.dart'; // FIX 1: Menambahkan import yang kurang
import 'note_edit_screen.dart';


// Enum untuk kriteria sorting
enum SortBy { date, title }

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // Daftar catatan dimulai dalam keadaan kosong
  final List<Note> notes = [];

  // Variabel State untuk Sorting
  SortBy _currentSortBy = SortBy.date;
  bool _isAscending = false;

  // State untuk mode seleksi
  bool _isSelectionMode = false;
  final Set<Note> _selectedNotes = {};

  @override
  void initState() {
    super.initState();
    _applySort();
  }

  void _applySort() {
    setState(() {
      if (_currentSortBy == SortBy.date) {
        if (_isAscending) {
          notes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        } else {
          notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }
      } else {
        if (_isAscending) {
          notes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        } else {
          notes.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        }
      }
    });
  }

  void _onSortCriteriaChanged(SortBy? newCriteria) {
    if (newCriteria != null && newCriteria != _currentSortBy) {
      setState(() {
        _currentSortBy = newCriteria;
        _isAscending = (_currentSortBy == SortBy.title);
      });
      _applySort();
    }
  }

  void _toggleSortDirection() {
    setState(() {
      _isAscending = !_isAscending;
    });
    _applySort();
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

  void _startSelection(Note note) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedNotes.add(note);
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotes.clear();
    });
  }

  void _selectAllNotes() {
    setState(() {
      if (_selectedNotes.length == notes.length) {
        _selectedNotes.clear();
      } else {
        _selectedNotes.addAll(notes);
      }
    });
  }


  void _deleteSelectedNotes() {
    setState(() {
      final int count = _selectedNotes.length;
      notes.removeWhere((note) => _selectedNotes.contains(note));
      _clearSelection();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$count catatan dihapus")));
    });
  }

  void _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen()),
    );
    if (newNote != null) {
      setState(() {
        notes.insert(0, newNote);
      });
      _applySort();
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: note)),
    );
    if (result != null) {
      if (result == 'deleted') {
        setState(() {
          notes.remove(note);
        });
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("Catatan dihapus")));
      } else if (result is Note) {
        setState(() {
          final originalIndex = notes.indexOf(note);
          if (originalIndex != -1) {
            notes[originalIndex] = result;
          }
        });
        _applySort();
      }
    }
  }

  String formatDate(DateTime date) {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    return "${date.day} ${monthNames[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    // FIX 2: Mendefinisikan themeProvider di dalam scope build
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: Drawer(
        // IMPROVEMENT: Menggunakan warna dari tema
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('Menu Catatan', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.label_outline),
              title: Text('Tag'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Sampah'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.folder_open_outlined),
              title: Text('Folder'),
              onTap: () => Navigator.pop(context),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Pengaturan'),
              onTap: () => Navigator.pop(context),
            ),
            // FIX 3: Memperbaiki sintaks Switch dan ListTile
            ListTile(
              title: Text('Mode Gelap'),
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  final provider = Provider.of<ThemeProvider>(context, listen: false);
                  provider.toggleTheme(value);
                },
              ), // Kurung tutup untuk Switch
            ), // Kurung tutup untuk ListTile
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.edit),
      ),
      body: SafeArea(
        child: _isSelectionMode
            ? _buildSelectionModeLayout()
            : _buildDefaultLayout(),
      ),
    );
  }

  Widget _buildSelectionModeLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildSelectionAppBar(),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final isSelected = _selectedNotes.contains(note);
                return _buildNoteTile(note, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLayout() {
    // IMPROVEMENT: Menggunakan warna dari tema agar dinamis
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodySmall!.color!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          expandedHeight: 176.0,
          pinned: true,
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Semua catatan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            background: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 65),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semua catatan',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: onBackgroundColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${notes.length} catatan',
                    style: TextStyle(fontSize: 16, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(56.0),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(builder: (context) {
                    return IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Buka menu',
                    );
                  }),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PopupMenuButton<SortBy>(
                        onSelected: _onSortCriteriaChanged,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<SortBy>>[
                          PopupMenuItem<SortBy>(value: SortBy.date, child: Text('Tanggal diubah')),
                          PopupMenuItem<SortBy>(value: SortBy.title, child: Text('Judul')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(20.0)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_currentSortBy == SortBy.date ? 'Tanggal diubah' : 'Judul', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(width: 5),
                              Icon(Icons.keyboard_arrow_down, color: secondaryTextColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                      IconButton(icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward), onPressed: _toggleSortDirection),
                      IconButton(icon: Icon(Icons.search), onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final note = notes[index];
                return _buildNoteTile(note, false);
              },
              childCount: notes.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteTile(Note note, bool isSelected) {
    return ListTile(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(note);
        } else {
          _editNote(note);
        }
      },
      onLongPress: () {
        _startSelection(note);
      },
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: _isSelectionMode
          ? Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      )
          : Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Icon(Icons.description, color: Colors.grey.shade500)),
      ),
      title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatDate(note.timestamp), style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _buildSelectionAppBar() {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.close), onPressed: _clearSelection),
              SizedBox(width: 16),
              Text('${_selectedNotes.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: _selectAllNotes,
                child: Text(
                  _selectedNotes.length == notes.length ? 'BATALKAN' : 'PILIH SEMUA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: _selectedNotes.isEmpty ? null : _deleteSelectedNotes,
                tooltip: 'Hapus',
              ),
            ],
          ),
        ],
      ),
    );
  }
}