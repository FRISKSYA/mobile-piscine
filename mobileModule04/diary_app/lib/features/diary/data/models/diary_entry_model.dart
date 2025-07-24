import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/diary_entry.dart';

part 'diary_entry_model.freezed.dart';

@freezed
class DiaryEntryModel with _$DiaryEntryModel {
  const factory DiaryEntryModel({
    required String id,
    required String userId,
    required String userEmail,
    required DateTime date,
    required String title,
    required String mood,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DiaryEntryModel;
  
  const DiaryEntryModel._();
  
  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      mood: json['mood'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_email': userEmail,
      'date': date.toIso8601String(),
      'title': title,
      'mood': mood,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  DiaryEntry toEntity() => DiaryEntry(
    id: id,
    userId: userId,
    userEmail: userEmail,
    date: date,
    title: title,
    mood: mood,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory DiaryEntryModel.fromEntity(DiaryEntry entity) {
    return DiaryEntryModel(
      id: entity.id,
      userId: entity.userId,
      userEmail: entity.userEmail,
      date: entity.date,
      title: entity.title,
      mood: entity.mood,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}