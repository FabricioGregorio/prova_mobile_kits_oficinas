import 'package:flutter/foundation.dart';

import '../core/network/erro_api.dart';
import '../core/session/sessao.dart';
import '../core/state/estado_tela.dart';
import '../model/usuario.dart';
import '../repository/usuario_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final UsuarioRepository repository;

  LoginViewModel({required this.repository});

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Usuario? usuario;

  Future<bool> entrar(String email, String senha) async {
    if (estado == EstadoTela.carregando) return false;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      usuario = await repository.entrar(email.trim(), senha);
      Sessao.usuario = usuario;
      estado = EstadoTela.sucesso;
      return true;
    } catch (erro) {
      // Credenciais incorretas: a API responde 401 com
      // {"message": "E-mail ou senha incorretos."}
      mensagemErro = mensagemDoErro(erro, 'Não foi possível entrar.');
      estado = EstadoTela.erro;
      return false;
    } finally {
      notifyListeners();
    }
  }
}
