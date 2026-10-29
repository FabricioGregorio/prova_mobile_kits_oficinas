import 'package:flutter/foundation.dart';

import '../core/network/erro_api.dart';
import '../core/state/estado_tela.dart';
import '../repository/usuario_repository.dart';

class CadastroUsuarioViewModel extends ChangeNotifier {
  final UsuarioRepository repository;

  CadastroUsuarioViewModel({required this.repository});

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Map<String, String> erros = {};

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (estado == EstadoTela.carregando) return false;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    erros = {};
    notifyListeners();
    try {
      await repository.cadastrar(nome: nome, email: email, senha: senha);
      estado = EstadoTela.sucesso;
      return true;
    } catch (erro) {
      mensagemErro = mensagemDoErro(erro, 'Não foi possível criar a conta.');
      erros = errosDosCampos(erro);
      estado = EstadoTela.erro;
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Evita avisar a view depois que a tela foi fechada.
  bool _descartado = false;

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
