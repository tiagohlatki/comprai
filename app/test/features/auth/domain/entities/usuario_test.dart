import 'package:comprai/features/auth/domain/entities/usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Usuario', () {
    const usuario = Usuario(id: '1', email: 'a@b.com', nome: 'Tiago');
    const mesmo = Usuario(id: '1', email: 'a@b.com', nome: 'Tiago');
    const diferente = Usuario(id: '2', email: 'x@y.com');

    test('dado_usuariosIguais_quando_comparados_entao_saoIguais', () {
      expect(usuario, equals(mesmo));
    });

    test('dado_usuariosDiferentes_quando_comparados_entao_naoSaoIguais', () {
      expect(usuario, isNot(equals(diferente)));
    });

    test('dado_usuario_quando_semNome_entao_nomeEhNulo', () {
      expect(diferente.nome, isNull);
    });

    test('dado_usuario_quando_criado_entao_emailCorreto', () {
      expect(usuario.email, equals('a@b.com'));
    });
  });
}
