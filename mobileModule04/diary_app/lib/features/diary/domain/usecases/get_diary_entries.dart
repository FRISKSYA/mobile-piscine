import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class GetDiaryEntries {
  final DiaryRepository repository;
  
  GetDiaryEntries(this.repository);
  
  Future<Either<Failure, List<DiaryEntry>>> call(String userId) async {
    return await repository.getDiaryEntries(userId);
  }
}