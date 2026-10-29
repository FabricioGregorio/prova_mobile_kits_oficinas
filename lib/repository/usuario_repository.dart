import '../core/network/cliente_api.dart';
import '../model/usuario.dart';

class UsuarioRepository {
  final ClienteApi cliente;

  UsuarioRepository(this.cliente);

  Future<Usuario> entrar(String email, String senha) async {
    final resposta = await cliente.dio.post(
      '/login',
      data: {'email': email, 'senha': senha},
    );
    return Usuario.fromJson(resposta.data as Map<String, dynamic>);
  }

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final resposta = await cliente.dio.post(
      '/usuarios',
      data: {'nome': nome, 'email': email, 'senha': senha},
    );
    return Usuario.fromJson(resposta.data as Map<String, dynamic>);
  }
}
