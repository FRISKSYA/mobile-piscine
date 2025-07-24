import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<Either<Failure, List<DiaryEntry>>> getDiaryEntries(String userId);
  Future<Either<Failure, DiaryEntry>> getDiaryEntry(String id);
  Future<Either<Failure, DiaryEntry>> createDiaryEntry({
    required String userId,
    required String userEmail,
    required DateTime date,
    required String title,
    required String mood,
    required String content,
  });
  Future<Either<Failure, DiaryEntry>> updateDiaryEntry(DiaryEntry entry);
  Future<Either<Failure, void>> deleteDiaryEntry(String id);
}