import 'package:equatable/equatable.dart';

class NfceEstabelecimento extends Equatable {
  final String cnpj;
  final String nome;
  final String endereco;
  final String? cidade;
  final String? estado;
  final double? latitude;
  final double? longitude;

  const NfceEstabelecimento({
    required this.cnpj,
    required this.nome,
    required this.endereco,
    this.cidade,
    this.estado,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    cnpj,
    nome,
    endereco,
    cidade,
    estado,
    latitude,
    longitude,
  ];
}

class NfceItem extends Equatable {
  final String nome;
  final String? ean;
  final double quantidade;
  final double precoUnitario;
  final double precoTotal;

  const NfceItem({
    required this.nome,
    this.ean,
    required this.quantidade,
    required this.precoUnitario,
    required this.precoTotal,
  });

  @override
  List<Object?> get props => [nome, ean, quantidade, precoUnitario, precoTotal];
}

class NfceData extends Equatable {
  final String chave;
  final NfceEstabelecimento estabelecimento;
  final List<NfceItem> itens;
  final double total;
  final DateTime dataCompra;

  const NfceData({
    required this.chave,
    required this.estabelecimento,
    required this.itens,
    required this.total,
    required this.dataCompra,
  });

  @override
  List<Object?> get props => [chave, estabelecimento, itens, total, dataCompra];
}
