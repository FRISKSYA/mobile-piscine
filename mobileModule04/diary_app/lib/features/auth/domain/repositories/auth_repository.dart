import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, DiaryUser>> signInWithGoogle();
  Future<Either<Failure, DiaryUser>> signInWithGitHub();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, DiaryUser?>> getCurrentUser();
  Stream<DiaryUser?> get authStateChanges;
}