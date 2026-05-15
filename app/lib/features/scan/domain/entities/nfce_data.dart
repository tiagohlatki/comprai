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

  factory NfceEstabelecimento.fromJson(Map<String, dynamic> json) {
    return NfceEstabelecimento(
      cnpj: (json['cnpj'] as String?) ?? '',
      nome: (json['nome'] as String?) ?? 'Estabelecimento',
      endereco: (json['endereco'] as String?) ?? '',
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

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

  factory NfceItem.fromJson(Map<String, dynamic> json) {
    return NfceItem(
      nome: (json['nome'] as String?) ?? '',
      ean: json['ean'] as String?,
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 1,
      precoUnitario: (json['precoUnitario'] as num?)?.toDouble() ?? 0,
      precoTotal: (json['precoTotal'] as num?)?.toDouble() ?? 0,
    );
  }

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

  factory NfceData.fromJson(Map<String, dynamic> json) {
    return NfceData(
      chave: (json['chave'] as String?) ?? '',
      estabelecimento: NfceEstabelecimento.fromJson(
        json['estabelecimento'] as Map<String, dynamic>? ?? {},
      ),
      itens: ((json['itens'] as List<dynamic>?) ?? [])
          .map((e) => NfceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      dataCompra:
          DateTime.tryParse(json['dataCompra'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [chave, estabelecimento, itens, total, dataCompra];
}
