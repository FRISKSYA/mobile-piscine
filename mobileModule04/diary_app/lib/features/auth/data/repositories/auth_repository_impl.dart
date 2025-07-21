import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, DiaryUser>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } on AppAuthException catch (e) {
      return Left(AppAuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, DiaryUser>> signInWithGitHub() async {
    try {
      final userModel = await remoteDataSource.signInWithGitHub();
      return Right(userModel.toEntity());
    } on AppAuthException catch (e) {
      return Left(AppAuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AppAuthException catch (e) {
      return Left(AppAuthFailure(e.message ?? 'Sign out failed'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, DiaryUser?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } on AppAuthException catch (e) {
      return Left(AppAuthFailure(e.message ?? 'Failed to get current user'));
    } catch (e) {
      return Left(AppServerFailure(e.toString()));
    }
  }
  
  @override
  Stream<DiaryUser?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) => userModel?.toEntity());
  }
}