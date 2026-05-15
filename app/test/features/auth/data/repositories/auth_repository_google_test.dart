import 'package:comprai/features/auth/data/repositories/auth_repository.dart';
import 'package:comprai/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockSupabaseClient supabaseClient;
  late _MockGoTrueClient goTrueClient;
  late AuthRepository repository;

  setUp(() {
    supabaseClient = _MockSupabaseClient();
    goTrueClient = _MockGoTrueClient();
    when(() => supabaseClient.auth).thenReturn(goTrueClient);
    when(
      () => goTrueClient.onAuthStateChange,
    ).thenAnswer((_) => const Stream.empty());
    repository = AuthRepository(supabaseClient);
  });

  group('AuthRepository', () {
    test('dado_repositorio_quando_criado_entao_implementaIAuthRepository', () {
      expect(repository, isA<IAuthRepository>());
    });

    test('dado_repositorio_quando_usuarioAtualNulo_entao_retornaNull', () {
      when(() => goTrueClient.currentUser).thenReturn(null);
      expect(repository.usuarioAtual, isNull);
    });

    test('dado_repositorio_quando_onAuthStateChange_entao_retornaStream', () {
      expect(repository.onAuthStateChange, isA<Stream>());
    });
  });
}
