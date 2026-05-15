import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/usuario_model.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final SupabaseClient _client;
  const AuthRepository(this._client);

  @override
  Future<Either<Failure, Usuario>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      final user = response.user;
      if (user == null) {
        return left(const AuthFailure('Login sem usuário retornado'));
      }
      return right(UsuarioModel.fromSupabaseUser(user));
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure('Erro de conexão. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, Usuario>> registrar({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client.auth.signUp(email: email, password: senha);
      final user = response.user;
      if (user == null) {
        return left(const AuthFailure('Cadastro sem usuário retornado'));
      }
      return right(UsuarioModel.fromSupabaseUser(user));
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure('Erro de conexão. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> loginComGoogle() async {
    try {
      // redirectTo aponta para a porta real do app em desenvolvimento web
      final redirectTo = kIsWeb ? Uri.base.origin : null;
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );
      return right(unit);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure('Erro de conexão. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sair() async {
    try {
      await _client.auth.signOut();
      return right(unit);
    } catch (_) {
      return left(const ServerFailure('Erro ao sair. Tente novamente.'));
    }
  }

  @override
  Usuario? get usuarioAtual {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UsuarioModel.fromSupabaseUser(user);
  }

  @override
  Stream<Usuario?> get onAuthStateChange =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return UsuarioModel.fromSupabaseUser(user);
      });
}
