import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final String id;
  final String email;
  final String? nome;
  final String? cidade;

  const Usuario({
    required this.id,
    required this.email,
    this.nome,
    this.cidade,
  });

  @override
  List<Object?> get props => [id, email, nome, cidade];
}
