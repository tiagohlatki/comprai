import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.email,
    super.nome,
    super.cidade,
  });

  factory UsuarioModel.fromSupabaseUser(User user) => UsuarioModel(
    id: user.id,
    email: user.email ?? '',
    nome: user.userMetadata?['nome'] as String?,
  );
}
