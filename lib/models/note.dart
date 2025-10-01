class Note {
  String title;
  String content;
  DateTime timestamp;
  Set<String> tags; 

  Note({
    required this.title,
    required this.content,
    required this.timestamp,
    Set<String>? tags,
  }) : this.tags = tags ?? {};
}
