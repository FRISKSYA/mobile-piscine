import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class CreateDiaryEntry {
  final DiaryRepository repository;
  
  CreateDiaryEntry(this.repository);
  
  Future<Either<Failure, DiaryEntry>> call(CreateDiaryEntryParams params) async {
    return await repository.createDiaryEntry(
      userId: params.userId,
      userEmail: params.userEmail,
      date: params.date,
      title: params.title,
      mood: params.mood,
      content: params.content,
    );
  }
}

class CreateDiaryEntryParams extends Equatable {
  final String userId;
  final String userEmail;
  final DateTime date;
  final String title;
  final String mood;
  final String content;
  
  const CreateDiaryEntryParams({
    required this.userId,
    required this.userEmail,
    required this.date,
    required this.title,
    required this.mood,
    required this.content,
  });
  
  @override
  List<Object> get props => [userId, userEmail, date, title, mood, content];
}