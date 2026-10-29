import 'package:flutter/foundation.dart';

import '../core/network/erro_api.dart';
import '../core/state/estado_tela.dart';
import '../model/material.dart';
import '../repository/kit_repository.dart';
import '../repository/material_repository.dart';

class DetalhesMaterialViewModel extends ChangeNotifier {
  final MaterialRepository materialRepository;
  final KitRepository kitRepository;
  final int materialId;
  final int usuarioId;

  DetalhesMaterialViewModel({
    required this.materialRepository,
    required this.kitRepository,
    required this.materialId,
    required this.usuarioId,
  });

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Material? material;

  bool adicionando = false;
  String? erroAcao;

  Future<void> carregar() async {
    if (estado == EstadoTela.carregando) return;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      material = await materialRepository.buscar(materialId);
      estado = EstadoTela.sucesso;
    } catch (erro) {
      mensagemErro =
          mensagemDoErro(erro, 'Não foi possível carregar o material.');
      estado = EstadoTela.erro;
    } finally {
      notifyListeners();
    }
  }

  /// Só altera o kit quando o usuário confirma a inclusão.
  Future<bool> adicionarAoKit(int quantidade) async {
    if (adicionando) return false;
    adicionando = true;
    erroAcao = null;
    notifyListeners();
    try {
      await kitRepository.adicionar(usuarioId, materialId, quantidade);
      return true;
    } catch (erro) {
      erroAcao = mensagemDoErro(erro, 'Não foi possível adicionar ao kit.');
      return false;
    } finally {
      adicionando = false;
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
