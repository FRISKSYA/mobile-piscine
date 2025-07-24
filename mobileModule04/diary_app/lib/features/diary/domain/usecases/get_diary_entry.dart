import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class GetDiaryEntry {
  final DiaryRepository repository;
  
  GetDiaryEntry(this.repository);
  
  Future<Either<Failure, DiaryEntry>> call(String id) async {
    return await repository.getDiaryEntry(id);
  }
}