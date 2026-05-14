import 'package:comprai/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    test('dado_authFailure_quando_criado_entao_temMensagem', () {
      const failure = AuthFailure('credenciais inválidas');
      expect(failure.message, equals('credenciais inválidas'));
    });

    test('dado_networkFailure_quando_criado_entao_temMensagem', () {
      const failure = NetworkFailure('sem conexão');
      expect(failure.message, equals('sem conexão'));
    });

    test('dado_falhasMesmoTipo_quando_mesmaMensagem_entao_saoIguais', () {
      const a = AuthFailure('erro');
      const b = AuthFailure('erro');
      expect(a, equals(b));
    });

    test('dado_falhasTiposDiferentes_quando_mesmaMensagem_entao_naoSaoIguais',
        () {
      const a = AuthFailure('erro');
      const b = NetworkFailure('erro');
      expect(a, isNot(equals(b)));
    });
  });
}
