class Note {
  String title;
  String content;
  DateTime timestamp; // last modified
  DateTime createdAt; // created time
  Set<String> tags;

  Note({
    required this.title,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    required this.tags,
  });
}
