import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, Usuario>> login({
    required String email,
    required String senha,
  });

  Future<Either<Failure, Usuario>> registrar({
    required String email,
    required String senha,
  });

  Future<Either<Failure, Unit>> sair();

  Usuario? get usuarioAtual;

  Stream<Usuario?> get onAuthStateChange;
}
