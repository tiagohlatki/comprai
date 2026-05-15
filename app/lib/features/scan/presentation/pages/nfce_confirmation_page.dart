import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/nfce_data.dart';

const _bg = Color(0xFF0D1117);
const _card = Color(0xFF161B22);
const _teal = Color(0xFF00B4D8);
const _tealDark = Color(0xFF0096B5);
const _border = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);

String _brl(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m/${dt.year}';
}

class NfceConfirmacaoPage extends StatefulWidget {
  const NfceConfirmacaoPage({super.key, required this.data});

  final NfceData data;

  @override
  State<NfceConfirmacaoPage> createState() => _NfceConfirmacaoPageState();
}

class _NfceConfirmacaoPageState extends State<NfceConfirmacaoPage> {
  bool _saving = false;

  Future<void> _salvar() async {
    setState(() => _saving = true);
    try {
      await _persistirNfce(widget.data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compra salva com sucesso! ✅',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on _DuplicateChaveException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta nota já foi salva anteriormente.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _card,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // -------------------------------------------------------------------------
  // Persistência no Supabase
  // -------------------------------------------------------------------------
  Future<void> _persistirNfce(NfceData data) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    // 1. Upsert estabelecimento (idempotente por CNPJ)
    final estabResp = await client
        .from('estabelecimentos')
        .upsert({
          'cnpj': _cleanCnpj(data.estabelecimento.cnpj),
          'nome': data.estabelecimento.nome,
          'endereco': data.estabelecimento.endereco,
          'cidade': data.estabelecimento.cidade,
          'estado': data.estabelecimento.estado,
          if (data.estabelecimento.latitude != null)
            'latitude': data.estabelecimento.latitude,
          if (data.estabelecimento.longitude != null)
            'longitude': data.estabelecimento.longitude,
        }, onConflict: 'cnpj')
        .select('id')
        .single();

    final estabelecimentoId = estabResp['id'] as String;

    // 2. Upsert produtos e inserir preços
    for (final item in data.itens) {
      final produtoId = await _upsertProduto(client, item);

      // 3. Insert preço (chave NFC-e garante idempotência via unique constraint)
      try {
        await client.from('precos').insert({
          'produto_id': produtoId,
          'estabelecimento_id': estabelecimentoId,
          'user_id': userId,
          'preco_unitario': item.precoUnitario,
          'data_compra': data.dataCompra.toIso8601String().substring(0, 10),
          'nfce_chave': data.chave,
        });
      } on PostgrestException catch (e) {
        // Código 23505 = unique violation → chave já salva
        if (e.code == '23505') throw const _DuplicateChaveException();
        rethrow;
      }
    }
  }

  Future<String> _upsertProduto(SupabaseClient client, NfceItem item) async {
    // Tenta por EAN primeiro (mais confiável)
    if (item.ean != null && item.ean!.isNotEmpty) {
      final resp = await client
          .from('produtos')
          .upsert({
            'ean': item.ean,
            'nome_canonical': item.nome.toUpperCase(),
          }, onConflict: 'ean')
          .select('id')
          .single();
      return resp['id'] as String;
    }

    // Sem EAN: tenta match por nome_canonical (case-insensitive)
    final existing = await client
        .from('produtos')
        .select('id')
        .ilike('nome_canonical', item.nome.trim())
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Não existe: insere novo produto
    final inserted = await client
        .from('produtos')
        .insert({'nome_canonical': item.nome.toUpperCase()})
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  String _cleanCnpj(String cnpj) => cnpj.replaceAll(RegExp(r'[^0-9]'), '');

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFF16A34A,
                              ).withValues(alpha: 0.15),
                              border: Border.all(
                                color: const Color(
                                  0xFF16A34A,
                                ).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF22C55E),
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'NFC-e lida com sucesso!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Store card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _teal.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  color: _teal,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  data.estabelecimento.nome,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'CNPJ: ${data.estabelecimento.cnpj}',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (data.estabelecimento.endereco.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: _textSecondary,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    data.estabelecimento.endereco,
                                    style: const TextStyle(
                                      color: _textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: _textSecondary,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(data.dataCompra),
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Items divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: _border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Itens',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: _border)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Items list
                    ...data.itens.map((item) {
                      final hasMultiple = item.quantidade > 1;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            if (hasMultiple)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.quantidade.toInt()}x',
                                  style: const TextStyle(
                                    color: _teal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (hasMultiple)
                                    Text(
                                      '${_brl(item.precoUnitario)} × ${item.quantidade.toInt()}',
                                      style: const TextStyle(
                                        color: _textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              _brl(item.precoTotal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Sticky bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: _card,
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _brl(data.total),
                        style: const TextStyle(
                          color: _teal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _saving
                          ? const LinearGradient(colors: [_card, _card])
                          : const LinearGradient(colors: [_teal, _tealDark]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _saving ? null : () => context.pop(),
                    child: const Text(
                      'Descartar',
                      style: TextStyle(color: _textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------
class _DuplicateChaveException implements Exception {
  const _DuplicateChaveException();
}
