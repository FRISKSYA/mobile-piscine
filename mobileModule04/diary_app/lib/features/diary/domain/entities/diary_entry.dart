import 'package:equatable/equatable.dart';

class DiaryEntry extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final DateTime date;
  final String title;
  final String mood;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const DiaryEntry({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.date,
    required this.title,
    required this.mood,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object> get props => [
    id,
    userId,
    userEmail,
    date,
    title,
    mood,
    content,
    createdAt,
    updatedAt,
  ];
}