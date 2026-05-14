import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/usuario.dart';
import '../domain/repositories/i_auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final IAuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<Failure, Usuario>> execute({
    required String email,
    required String senha,
  }) =>
      _repository.login(email: email, senha: senha);
}
