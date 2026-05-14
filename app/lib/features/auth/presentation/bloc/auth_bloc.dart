import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../application/login_use_case.dart';
import '../../application/registrar_use_case.dart';
import '../../application/sair_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final RegistrarUseCase _registrar;
  final SairUseCase _sair;

  AuthBloc(this._login, this._registrar, this._sair)
    : super(const AuthInicial()) {
    on<AuthLoginSolicitado>(_onLoginSolicitado);
    on<AuthRegistroSolicitado>(_onRegistroSolicitado);
    on<AuthSairSolicitado>(_onSairSolicitado);
  }

  Future<void> _onLoginSolicitado(
    AuthLoginSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    final result = await _login.execute(email: event.email, senha: event.senha);
    result.fold(
      (failure) => emit(AuthErro(failure.message)),
      (usuario) => emit(AuthAutenticado(usuario)),
    );
  }

  Future<void> _onRegistroSolicitado(
    AuthRegistroSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    final result = await _registrar.execute(
      email: event.email,
      senha: event.senha,
    );
    result.fold(
      (failure) => emit(AuthErro(failure.message)),
      (usuario) => emit(AuthAutenticado(usuario)),
    );
  }

  Future<void> _onSairSolicitado(
    AuthSairSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    final result = await _sair.execute();
    result.fold(
      (failure) => emit(AuthErro(failure.message)),
      (_) => emit(const AuthNaoAutenticado()),
    );
  }
}
