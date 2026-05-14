import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../domain/repositories/i_auth_repository.dart';

@lazySingleton
class SairUseCase {
  final IAuthRepository _repository;
  const SairUseCase(this._repository);

  Future<Either<Failure, Unit>> execute() => _repository.sair();
}
