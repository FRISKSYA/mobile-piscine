import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;
  
  SignOut(this.repository);
  
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}