import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/usuario.dart';
import '../domain/repositories/i_auth_repository.dart';

@lazySingleton
class RegistrarUseCase {
  final IAuthRepository _repository;
  const RegistrarUseCase(this._repository);

  Future<Either<Failure, Usuario>> execute({
    required String email,
    required String senha,
  }) =>
      _repository.registrar(email: email, senha: senha);
}
