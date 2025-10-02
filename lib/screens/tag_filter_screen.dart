import 'package:flutter/material.dart';

class TagFilterScreen extends StatefulWidget {
  final Set<String> allTags;
  final Set<String> initiallySelectedTags;

  const TagFilterScreen({
    super.key,
    required this.allTags,
    required this.initiallySelectedTags,
  });

  @override
  State<TagFilterScreen> createState() => _TagFilterScreenState();
}

class _TagFilterScreenState extends State<TagFilterScreen> {
  late Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = Set.from(widget.initiallySelectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final sortedTags = widget.allTags.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tag'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTags.clear();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            child: const Text('HAPUS SEMUA'),
          )
        ],
      ),
      body: widget.allTags.isEmpty
          ? Center(
        child: Text(
          'Tidak ada tag untuk difilter.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: sortedTags.map((tag) {
            return FilterChip(
              label: Text(tag),
              selected: _selectedTags.contains(tag),
              onSelected: (bool isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _selectedTags);
        },
        label: const Text('Terapkan Filter'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}