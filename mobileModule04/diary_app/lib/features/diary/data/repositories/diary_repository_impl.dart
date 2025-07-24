import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_remote_datasource.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryRemoteDataSource remoteDataSource;
  
  DiaryRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, List<DiaryEntry>>> getDiaryEntries(String userId) async {
    try {
      final models = await remoteDataSource.getDiaryEntries(userId);
      final entries = models.map((model) => model.toEntity()).toList();
      return Right(entries);
    } on AppServerException catch (e) {
      return Left(AppServerFailure(e.message ?? 'Failed to get diary entries'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, DiaryEntry>> getDiaryEntry(String id) async {
    try {
      final model = await remoteDataSource.getDiaryEntry(id);
      return Right(model.toEntity());
    } on AppServerException catch (e) {
      return Left(AppServerFailure(e.message ?? 'Failed to get diary entry'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, DiaryEntry>> createDiaryEntry({
    required String userId,
    required String userEmail,
    required DateTime date,
    required String title,
    required String mood,
    required String content,
  }) async {
    try {
      final model = await remoteDataSource.createDiaryEntry(
        userId: userId,
        userEmail: userEmail,
        date: date,
        title: title,
        mood: mood,
        content: content,
      );
      return Right(model.toEntity());
    } on AppServerException catch (e) {
      return Left(AppServerFailure(e.message ?? 'Failed to create diary entry'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, DiaryEntry>> updateDiaryEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      final updatedModel = await remoteDataSource.updateDiaryEntry(model);
      return Right(updatedModel.toEntity());
    } on AppServerException catch (e) {
      return Left(AppServerFailure(e.message ?? 'Failed to update diary entry'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteDiaryEntry(String id) async {
    try {
      await remoteDataSource.deleteDiaryEntry(id);
      return const Right(null);
    } on AppServerException catch (e) {
      return Left(AppServerFailure(e.message ?? 'Failed to delete diary entry'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
}