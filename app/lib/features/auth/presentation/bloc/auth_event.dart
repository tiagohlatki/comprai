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

final class AuthGoogleLoginSolicitado extends AuthEvent {
  const AuthGoogleLoginSolicitado();
}

final class AuthSairSolicitado extends AuthEvent {
  const AuthSairSolicitado();
}

// Evento interno — disparado pelo stream onAuthStateChange do Supabase
final class AuthSessaoAlterada extends AuthEvent {
  final dynamic usuario;
  const AuthSessaoAlterada(this.usuario);

  @override
  List<Object?> get props => [usuario];
}
