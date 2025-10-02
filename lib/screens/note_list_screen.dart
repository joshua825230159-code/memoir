import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import 'note_edit_screen.dart';
import 'tag_filter_screen.dart';
import 'trash_screen.dart';

enum SortBy { dateModified, dateCreated, title }

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final List<Note> notes = [];
  final List<Note> _deletedNotes = [];

  SortBy _currentSortBy = SortBy.dateModified;
  bool _isAscending = false;

  Set<String> _activeFilterTags = {};
  bool _isSelectionMode = false;
  final Set<Note> _selectedNotes = {};

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _applySort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> get _filteredNotes {
    List<Note> filtered = notes;

    if (_activeFilterTags.isNotEmpty) {
      filtered = filtered.where((note) =>
          _activeFilterTags.every((tag) => note.tags.contains(tag))).toList();
    }

    if (_isSearching && _searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) =>
      note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  Set<String> get _allAvailableTags {
    return notes.expand((note) => note.tags).toSet();
  }

  void _applySort() {
    setState(() {
      if (_currentSortBy == SortBy.dateModified) {
        notes.sort((a, b) =>
        _isAscending ? a.timestamp.compareTo(b.timestamp) : b.timestamp.compareTo(a.timestamp));
      } else if (_currentSortBy == SortBy.dateCreated) {
        notes.sort((a, b) =>
        _isAscending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
      } else {
        notes.sort((a, b) => _isAscending
            ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
            : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      }
    });
  }

  void _onSortCriteriaChanged(SortBy? newCriteria) {
    if (newCriteria != null && newCriteria != _currentSortBy) {
      setState(() {
        _currentSortBy = newCriteria;
        _isAscending = (newCriteria == SortBy.title);
      });
      _applySort();
    }
  }

  void _toggleSortDirection() {
    setState(() => _isAscending = !_isAscending);
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
    final notesToSelect = _filteredNotes;
    setState(() {
      if (_selectedNotes.length == notesToSelect.length) {
        _selectedNotes.clear();
      } else {
        _selectedNotes.addAll(notesToSelect);
      }
    });
  }

  void _deleteSelectedNotes() {
    setState(() {
      final count = _selectedNotes.length;
      _deletedNotes.addAll(_selectedNotes);
      notes.removeWhere((note) => _selectedNotes.contains(note));
      _clearSelection();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$count catatan dipindahkan ke sampah")));
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
          _deletedNotes.add(note);
          notes.remove(note);
        });
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("Catatan dipindahkan ke sampah")));
      } else if (result is Note) {
        setState(() {
          final index = notes.indexOf(note);
          if (index != -1) notes[index] = result;
        });
        _applySort();
      }
    }
  }

  void _openTagFilter() async {
    Navigator.pop(context);
    final selectedTags = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => TagFilterScreen(
          allTags: _allAvailableTags,
          initiallySelectedTags: _activeFilterTags,
        ),
      ),
    );
    if (selectedTags != null) {
      setState(() => _activeFilterTags = selectedTags);
    }
  }

  void _openTrashScreen() async {
    Navigator.pop(context);
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => TrashScreen(deletedNotes: _deletedNotes),
      ),
    );

    if (result != null) {
      setState(() {
        final List<Note> restoredNotes = result['restored'] ?? [];
        final bool wasEmptied = result['emptied'] ?? false;

        if (wasEmptied) {
          _deletedNotes.clear();
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("Sampah dikosongkan")));
        } else if (restoredNotes.isNotEmpty) {
          notes.addAll(restoredNotes);
          _deletedNotes.removeWhere((note) => restoredNotes.contains(note));
           ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("${restoredNotes.length} catatan dipulihkan")));
        }
        _applySort();
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  String formatDate(DateTime date) {
    const monthNames = ["Jan","Feb","Mar","Apr","Mei","Jun","Jul","Agu","Sep","Okt","Nov","Des"];
    return "${date.day} ${monthNames[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentNotes = _filteredNotes;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('Menu Catatan', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.label_outline),
              title: Text('Tag'),
              onTap: _openTagFilter,
            ),
            ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Sampah'),
              onTap: _openTrashScreen,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Pengaturan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Mode Gelap'),
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (_isSelectionMode || _isSearching) ? null : FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.edit),
      ),
      body: SafeArea(
        child: _isSelectionMode ? _buildSelectionMode(currentNotes) : _buildDefaultLayout(currentNotes),
      ),
    );
  }

  Widget _buildSelectionMode(List<Note> currentNotes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildSelectionAppBar(),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: currentNotes.length,
              itemBuilder: (context, index) {
                final note = currentNotes[index];
                final isSelected = _selectedNotes.contains(note);
                return _buildNoteTile(note, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLayout(List<Note> currentNotes) {
    final onBg = Theme.of(context).colorScheme.onBackground;
    final secTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          expandedHeight: 176,
          pinned: true,
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Semua catatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            background: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 65),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Semua catatan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: onBg)),
                  SizedBox(height: 4),
                  Text(_isSearching ? '${currentNotes.length} hasil ditemukan' : '${currentNotes.length} catatan', style: TextStyle(fontSize: 16, color: secTextColor)),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: _isSearching ? _buildSearchBar(secTextColor, onBg) : _buildNormalAppBar(secTextColor),
            ),
          ),
        ),
        if (_activeFilterTags.isNotEmpty && !_isSearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ..._activeFilterTags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => setState(() => _activeFilterTags.remove(tag)),
                  )),
                  GestureDetector(
                    onTap: () => setState(() => _activeFilterTags.clear()),
                    child: Chip(
                      label: Text('Hapus Semua', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      avatar: Icon(Icons.close, color: Theme.of(context).colorScheme.error, size: 18),
                      backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildNoteTile(currentNotes[index], false),
              childCount: currentNotes.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNormalAppBar(Color secTextColor) {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Spacer(),
        PopupMenuButton<SortBy>(
          onSelected: _onSortCriteriaChanged,
          itemBuilder: (_) => [
            PopupMenuItem(value: SortBy.dateModified, child: Text('Tanggal diubah')),
            PopupMenuItem(value: SortBy.dateCreated, child: Text('Tanggal dibuat')),
            PopupMenuItem(value: SortBy.title, child: Text('Judul')),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentSortBy == SortBy.dateModified
                      ? 'Tanggal diubah'
                      : _currentSortBy == SortBy.dateCreated
                      ? 'Tanggal dibuat'
                      : 'Judul',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down, color: secTextColor, size: 20),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: _toggleSortDirection,
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color secTextColor, Color onBg) {
    return Expanded(
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back), onPressed: _toggleSearch),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Cari catatan...', border: InputBorder.none, hintStyle: TextStyle(color: secTextColor)),
              style: TextStyle(color: onBg),
            ),
          ),
          if (_searchQuery.isNotEmpty) IconButton(icon: Icon(Icons.clear), onPressed: () => _searchController.clear()),
        ],
      ),
    );
  }

  Widget _buildNoteTile(Note note, bool isSelected) {
    final primaryColor = Theme.of(context).primaryColor;
    final bodySmallStyle = Theme.of(context).textTheme.bodySmall;

    return ListTile(
      onTap: () => _isSelectionMode ? _toggleSelection(note) : _editNote(note),
      onLongPress: () => _startSelection(note),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      tileColor: isSelected ? primaryColor.withOpacity(0.2) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: _isSelectionMode
          ? Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? primaryColor : Colors.grey)
          : Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Icon(Icons.description, color: Colors.grey.shade500)),
      ),
      title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatDate(note.timestamp), style: bodySmallStyle),
          if (note.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(note.tags.map((t) => '#$t').join(' '), style: bodySmallStyle?.copyWith(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionAppBar() {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(icon: Icon(Icons.close), onPressed: _clearSelection),
            SizedBox(width: 16),
            Text('${_selectedNotes.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          Row(children: [
            TextButton(
              onPressed: _selectAllNotes,
              child: Text(_selectedNotes.length == _filteredNotes.length ? 'BATALKAN' : 'PILIH SEMUA', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(icon: Icon(Icons.delete_outline), onPressed: _selectedNotes.isEmpty ? null : _deleteSelectedNotes),
          ]),
        ],
      ),
    );
  }
}
