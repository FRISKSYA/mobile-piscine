import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;
  
  SignInWithGoogle(this.repository);
  
  Future<Either<Failure, DiaryUser>> call() async {
    return await repository.signInWithGoogle();
  }
}