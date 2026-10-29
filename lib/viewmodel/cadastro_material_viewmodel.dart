import 'package:flutter/foundation.dart';

import '../core/network/erro_api.dart';
import '../core/state/estado_tela.dart';
import '../repository/material_repository.dart';

class CadastroMaterialViewModel extends ChangeNotifier {
  final MaterialRepository repository;

  CadastroMaterialViewModel({required this.repository});

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Map<String, String> erros = {};

  Future<bool> cadastrar({
    required String nome,
    required String descricao,
    required String categoria,
    required double preco,
    String? imagemUrl,
  }) async {
    if (estado == EstadoTela.carregando) return false;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    erros = {};
    notifyListeners();
    try {
      await repository.cadastrar(
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        preco: preco,
        imagemUrl: imagemUrl,
      );
      estado = EstadoTela.sucesso;
      return true;
    } catch (erro) {
      mensagemErro =
          mensagemDoErro(erro, 'Não foi possível cadastrar o material.');
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
