import '../core/network/cliente_api.dart';
import '../model/material.dart';

class MaterialRepository {
  final ClienteApi cliente;

  MaterialRepository(this.cliente);

  Future<List<Material>> listar() async {
    final resposta = await cliente.dio.get('/materiais');
    return (resposta.data as List)
        .map((material) => Material.fromJson(material as Map<String, dynamic>))
        .toList();
  }

  Future<Material> buscar(int id) async {
    final resposta = await cliente.dio.get('/materiais/$id');
    return Material.fromJson(resposta.data as Map<String, dynamic>);
  }

  Future<Material> cadastrar({
    required String nome,
    required String descricao,
    required String categoria,
    required double preco,
    String? imagemUrl,
  }) async {
    final resposta = await cliente.dio.post(
      '/materiais',
      data: {
        'nome': nome,
        'descricao': descricao,
        'categoria': categoria,
        'preco': preco,
        // Sem URL, a API usa a imagem padrão.
        if (imagemUrl != null && imagemUrl.isNotEmpty) 'imagemUrl': imagemUrl,
      },
    );
    return Material.fromJson(resposta.data as Map<String, dynamic>);
  }
}
