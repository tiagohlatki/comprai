import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginSolicitado extends AuthEvent {
  final String email;
  final String senha;
  const AuthLoginSolicitado({required this.email, required this.senha});

  @override
  List<Object?> get props => [email, senha];
}

final class AuthRegistroSolicitado extends AuthEvent {
  final String email;
  final String senha;
  const AuthRegistroSolicitado({required this.email, required this.senha});

  @override
  List<Object?> get props => [email, senha];
}

final class AuthSairSolicitado extends AuthEvent {
  const AuthSairSolicitado();
}
