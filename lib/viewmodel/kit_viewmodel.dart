import 'package:flutter/foundation.dart';

import '../core/network/erro_api.dart';
import '../core/state/estado_tela.dart';
import '../model/kit.dart';
import '../repository/kit_repository.dart';

class KitViewModel extends ChangeNotifier {
  final KitRepository repository;
  final int usuarioId;

  KitViewModel({required this.repository, required this.usuarioId})
      : kit = Kit.vazio(usuarioId: usuarioId);

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Kit kit;

  // Operações sobre o kit já carregado (PATCH / DELETE).
  bool atualizando = false;
  String? erroAcao;

  Future<void> carregar() async {
    if (estado == EstadoTela.carregando || atualizando) return;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      kit = await repository.buscar(usuarioId);
      estado = EstadoTela.sucesso;
    } catch (erro) {
      mensagemErro = mensagemDoErro(erro, 'Não foi possível carregar o kit.');
      estado = EstadoTela.erro;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> alterarQuantidade(int materialId, int quantidade) => _executar(
      () => repository.alterarQuantidade(usuarioId, materialId, quantidade));

  Future<bool> remover(int materialId) =>
      _executar(() => repository.remover(usuarioId, materialId));

  Future<bool> limpar() => _executar(() => repository.limpar(usuarioId));

  // Avisa a view ao iniciar e ao concluir; o kit é substituído pela resposta
  // da API.
  Future<bool> _executar(Future<Kit> Function() operacao) async {
    if (atualizando || estado == EstadoTela.carregando) return false;
    atualizando = true;
    erroAcao = null;
    notifyListeners();
    try {
      kit = await operacao();
      return true;
    } catch (erro) {
      erroAcao = mensagemDoErro(erro, 'Não foi possível atualizar o kit.');
      return false;
    } finally {
      atualizando = false;
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
