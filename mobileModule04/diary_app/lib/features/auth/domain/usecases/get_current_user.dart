import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;
  
  GetCurrentUser(this.repository);
  
  Future<Either<Failure, DiaryUser?>> call() async {
    return await repository.getCurrentUser();
  }
}