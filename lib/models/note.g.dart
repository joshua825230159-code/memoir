// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
  id: json['id'] as String?,
  title: json['title'] as String,
  content: json['content'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toSet(),
  isPinned: json['isPinned'] as bool? ?? false,
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'timestamp': instance.timestamp.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'tags': instance.tags.toList(),
  'isPinned': instance.isPinned,
};
