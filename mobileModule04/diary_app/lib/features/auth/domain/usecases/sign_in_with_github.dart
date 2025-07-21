import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGitHub {
  final AuthRepository repository;
  
  SignInWithGitHub(this.repository);
  
  Future<Either<Failure, DiaryUser>> call() async {
    return await repository.signInWithGitHub();
  }
}