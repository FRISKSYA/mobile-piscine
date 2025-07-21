import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class AppServerFailure extends Failure {
  const AppServerFailure(super.message);
}

class AppCacheFailure extends Failure {
  const AppCacheFailure(super.message);
}

class AppAuthFailure extends Failure {
  const AppAuthFailure(super.message);
}

class AppValidationFailure extends Failure {
  const AppValidationFailure(super.message);
}