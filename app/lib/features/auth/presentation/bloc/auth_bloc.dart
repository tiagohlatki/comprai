import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../application/login_com_google_use_case.dart';
import '../../application/login_use_case.dart';
import '../../application/registrar_use_case.dart';
import '../../application/sair_use_case.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final RegistrarUseCase _registrar;
  final SairUseCase _sair;
  final LoginComGoogleUseCase _loginComGoogle;
  final IAuthRepository _authRepository;

  late final StreamSubscription<Usuario?> _authStateSub;

  AuthBloc(
    this._login,
    this._registrar,
    this._sair,
    this._loginComGoogle,
    this._authRepository,
  ) : super(const AuthInicial()) {
    on<AuthLoginSolicitado>(_onLoginSolicitado);
    on<AuthRegistroSolicitado>(_onRegistroSolicitado);
    on<AuthGoogleLoginSolicitado>(_onGoogleLoginSolicitado);
    on<AuthSairSolicitado>(_onSairSolicitado);
    on<AuthSessaoAlterada>(_onEstadoAlterado);

    // Escuta mudanças de sessão do Supabase (cobre o callback do OAuth Google)
    _authStateSub = _authRepository.onAuthStateChange.listen(
      (usuario) => add(AuthSessaoAlterada(usuario)),
    );
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

  Future<void> _onGoogleLoginSolicitado(
    AuthGoogleLoginSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    final result = await _loginComGoogle.execute();
    result.fold(
      (failure) => emit(AuthErro(failure.message)),
      // Sucesso = browser OAuth foi aberto; navegação ocorre via _onEstadoAlterado
      (_) => null,
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

  Future<void> _onEstadoAlterado(
    AuthSessaoAlterada event,
    Emitter<AuthState> emit,
  ) async {
    if (event.usuario != null) {
      emit(AuthAutenticado(event.usuario as Usuario));
    }
  }

  @override
  Future<void> close() {
    _authStateSub.cancel();
    return super.close();
  }
}
