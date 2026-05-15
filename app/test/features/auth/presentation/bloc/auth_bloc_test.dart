import 'dart:async';

import 'package:comprai/core/errors/failures.dart';
import 'package:comprai/features/auth/application/login_com_google_use_case.dart';
import 'package:comprai/features/auth/application/login_use_case.dart';
import 'package:comprai/features/auth/application/registrar_use_case.dart';
import 'package:comprai/features/auth/application/sair_use_case.dart';
import 'package:comprai/features/auth/domain/entities/usuario.dart';
import 'package:comprai/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:comprai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:comprai/features/auth/presentation/bloc/auth_event.dart';
import 'package:comprai/features/auth/presentation/bloc/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockRegistrarUseCase extends Mock implements RegistrarUseCase {}

class _MockSairUseCase extends Mock implements SairUseCase {}

class _MockLoginComGoogleUseCase extends Mock
    implements LoginComGoogleUseCase {}

class _MockAuthRepository extends Mock implements IAuthRepository {}

const _usuario = Usuario(id: 'u1', email: 'test@test.com');

void main() {
  late _MockLoginUseCase loginUseCase;
  late _MockRegistrarUseCase registrarUseCase;
  late _MockSairUseCase sairUseCase;
  late _MockLoginComGoogleUseCase loginComGoogleUseCase;
  late _MockAuthRepository authRepository;
  late StreamController<Usuario?> authStateController;

  AuthBloc buildBloc() => AuthBloc(
    loginUseCase,
    registrarUseCase,
    sairUseCase,
    loginComGoogleUseCase,
    authRepository,
  );

  setUp(() {
    loginUseCase = _MockLoginUseCase();
    registrarUseCase = _MockRegistrarUseCase();
    sairUseCase = _MockSairUseCase();
    loginComGoogleUseCase = _MockLoginComGoogleUseCase();
    authRepository = _MockAuthRepository();
    authStateController = StreamController<Usuario?>.broadcast();

    when(
      () => authRepository.onAuthStateChange,
    ).thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthBloc — estado inicial', () {
    test('dado_blocCriado_quando_nenhumEvento_entao_estadoEhInicial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<AuthInicial>());
      bloc.close();
    });
  });

  group('AuthBloc — AuthLoginSolicitado', () {
    test(
      'dado_credenciaisValidas_quando_loginSolicitado_entao_emiteCarregandoEAutenticado',
      () async {
        when(
          () => loginUseCase.execute(
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          ),
        ).thenAnswer((_) async => right(_usuario));

        final bloc = buildBloc();
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(
          const AuthLoginSolicitado(email: 'test@test.com', senha: '123456'),
        );
        await Future<void>.delayed(Duration.zero);

        expect(states, [isA<AuthCarregando>(), isA<AuthAutenticado>()]);
        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'dado_credenciaisInvalidas_quando_loginSolicitado_entao_emiteCarregandoEErro',
      () async {
        when(
          () => loginUseCase.execute(
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          ),
        ).thenAnswer(
          (_) async => left(const AuthFailure('Credenciais inválidas')),
        );

        final bloc = buildBloc();
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(
          const AuthLoginSolicitado(email: 'test@test.com', senha: 'wrong'),
        );
        await Future<void>.delayed(Duration.zero);

        expect(states, [isA<AuthCarregando>(), isA<AuthErro>()]);
        final erro = states.last as AuthErro;
        expect(erro.mensagem, equals('Credenciais inválidas'));
        await sub.cancel();
        await bloc.close();
      },
    );
  });

  group('AuthBloc — AuthGoogleLoginSolicitado', () {
    test(
      'dado_googleComSucesso_quando_googleLoginSolicitado_entao_emiteCarregando',
      () async {
        when(
          () => loginComGoogleUseCase.execute(),
        ).thenAnswer((_) async => right(unit));

        final bloc = buildBloc();
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthGoogleLoginSolicitado());
        await Future<void>.delayed(Duration.zero);

        expect(states, [isA<AuthCarregando>()]);
        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'dado_googleComFalha_quando_googleLoginSolicitado_entao_emiteErro',
      () async {
        when(
          () => loginComGoogleUseCase.execute(),
        ).thenAnswer((_) async => left(const NetworkFailure('Sem conexão')));

        final bloc = buildBloc();
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthGoogleLoginSolicitado());
        await Future<void>.delayed(Duration.zero);

        expect(states, [isA<AuthCarregando>(), isA<AuthErro>()]);
        await sub.cancel();
        await bloc.close();
      },
    );
  });

  group('AuthBloc — AuthSessaoAlterada', () {
    test(
      'dado_streamComUsuario_quando_sessaoAlterada_entao_emiteAutenticado',
      () async {
        final bloc = buildBloc();
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        authStateController.add(_usuario);
        await Future<void>.delayed(Duration.zero);

        expect(states, [isA<AuthAutenticado>()]);
        final autenticado = states.first as AuthAutenticado;
        expect(autenticado.usuario, equals(_usuario));
        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'dado_streamComNull_quando_sessaoAlterada_entao_naoEmiteNovoEstado',
      () async {
        final bloc = buildBloc();
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        authStateController.add(null);
        await Future<void>.delayed(Duration.zero);

        expect(states, isEmpty);
        await sub.cancel();
        await bloc.close();
      },
    );
  });
}
