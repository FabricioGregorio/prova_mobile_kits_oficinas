import '../core/network/cliente_api.dart';
import '../model/kit.dart';

class KitRepository {
  final ClienteApi cliente;

  KitRepository(this.cliente);

  Future<Kit> buscar(int usuarioId) async {
    final resposta = await cliente.dio.get(
      '/kit',
      queryParameters: {'usuarioId': usuarioId},
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  /// POST /kit soma a quantidade à que já existe no kit.
  Future<Kit> adicionar(int usuarioId, int materialId, int quantidade) async {
    final resposta = await cliente.dio.post(
      '/kit',
      data: {
        'usuarioId': usuarioId,
        'materialId': materialId,
        'quantidade': quantidade,
      },
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  /// PATCH substitui a quantidade existente.
  Future<Kit> alterarQuantidade(
    int usuarioId,
    int materialId,
    int quantidade,
  ) async {
    final resposta = await cliente.dio.patch(
      '/kit/$materialId',
      data: {'usuarioId': usuarioId, 'quantidade': quantidade},
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  Future<Kit> remover(int usuarioId, int materialId) async {
    final resposta = await cliente.dio.delete(
      '/kit/$materialId',
      queryParameters: {'usuarioId': usuarioId},
    );
    return _kitDaResposta(resposta.data, usuarioId);
  }

  Future<Kit> limpar(int usuarioId) async {
    final resposta = await cliente.dio.delete(
      '/kit',
      queryParameters: {'usuarioId': usuarioId},
    );
    return _kitDaResposta(resposta.data, usuarioId);
  }

  // Usa o kit devolvido pelo DELETE; se a resposta não trouxer o kit,
  // consulta novamente o kit do usuário.
  Future<Kit> _kitDaResposta(dynamic dados, int usuarioId) async {
    if (dados is Map<String, dynamic> && dados['itens'] is List) {
      return Kit.fromJson(dados);
    }
    return buscar(usuarioId);
  }
}
