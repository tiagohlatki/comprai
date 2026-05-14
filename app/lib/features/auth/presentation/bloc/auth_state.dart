import 'package:equatable/equatable.dart';

import '../../domain/entities/usuario.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInicial extends AuthState {
  const AuthInicial();
}

final class AuthCarregando extends AuthState {
  const AuthCarregando();
}

final class AuthAutenticado extends AuthState {
  final Usuario usuario;
  const AuthAutenticado(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

final class AuthNaoAutenticado extends AuthState {
  const AuthNaoAutenticado();
}

final class AuthErro extends AuthState {
  final String mensagem;
  const AuthErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
