import 'package:comprai/core/errors/failures.dart';
import 'package:comprai/features/auth/application/login_com_google_use_case.dart';
import 'package:comprai/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginComGoogleUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginComGoogleUseCase(repository);
  });

  group('LoginComGoogleUseCase', () {
    test(
      'dado_repositorioComSucesso_quando_execute_entao_retornaUnit',
      () async {
        when(
          () => repository.loginComGoogle(),
        ).thenAnswer((_) async => right(unit));

        final result = await useCase.execute();

        expect(result, equals(right<Failure, Unit>(unit)));
        verify(() => repository.loginComGoogle()).called(1);
      },
    );

    test(
      'dado_repositorioComFalha_quando_execute_entao_retornaFailure',
      () async {
        const failure = AuthFailure('Erro ao autenticar com Google');
        when(
          () => repository.loginComGoogle(),
        ).thenAnswer((_) async => left(failure));

        final result = await useCase.execute();

        expect(result, equals(left<Failure, Unit>(failure)));
      },
    );
  });
}
