import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

@JsonSerializable()
class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final DateTime createdAt;
  final Set<String> tags;
  final bool isPinned;

  Note({
    String? id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    required this.tags,
    this.isPinned = false,
  }) : id = id ?? const Uuid().v4();

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    DateTime? createdAt,
    Set<String>? tags,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  @override
  List<Object?> get props => [id, title, content, timestamp, createdAt, tags, isPinned];
}