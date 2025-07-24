import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/diary_repository.dart';

class DeleteDiaryEntry {
  final DiaryRepository repository;
  
  DeleteDiaryEntry(this.repository);
  
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteDiaryEntry(id);
  }
}