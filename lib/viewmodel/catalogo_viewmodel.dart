import 'package:flutter/foundation.dart';

import '../core/network/erro_api.dart';
import '../core/state/estado_tela.dart';
import '../model/kit.dart';
import '../model/material.dart';
import '../repository/kit_repository.dart';
import '../repository/material_repository.dart';

class CatalogoViewModel extends ChangeNotifier {
  final MaterialRepository materialRepository;
  final KitRepository kitRepository;
  final int usuarioId;

  CatalogoViewModel({
    required this.materialRepository,
    required this.kitRepository,
    required this.usuarioId,
  }) : kit = Kit.vazio(usuarioId: usuarioId);

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  List<Material> materiais = [];
  Kit kit;

  List<String> get categorias =>
      materiais.map((material) => material.categoria).toSet().toList()..sort();

  /// Pesquisa por nome e filtro por categoria sobre a lista já recebida.
  List<Material> filtrar(String busca, String? categoria) {
    final termo = busca.trim().toLowerCase();
    return materiais.where((material) {
      final nomeConfere =
          termo.isEmpty || material.nome.toLowerCase().contains(termo);
      final categoriaConfere =
          categoria == null || material.categoria == categoria;
      return nomeConfere && categoriaConfere;
    }).toList();
  }

  bool _permitidoNoCatalogo(Material material) {
    final categoria = material.categoria.trim().toLowerCase();
    final nome = material.nome.trim().toLowerCase();

    // Remove Jardinagem
    if (categoria == 'jardinagem') {
      return false;
    }

    // Remove Eletrônica / Eletrocina
    if (categoria == 'eletrônica' ||
        categoria == 'eletronica' ||
        categoria == 'eletrocina') {
      return false;
    }

    // Remove Geral (exceto mochila)
    if (categoria == 'geral' && !nome.contains('mochila')) {
      return false;
    }

    return true;
  }

  Future<void> carregar() async {
    if (estado == EstadoTela.carregando) return;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      final lista = await materialRepository.listar();
      materiais = lista.where(_permitidoNoCatalogo).toList();
      kit = await kitRepository.buscar(usuarioId);
      estado = EstadoTela.sucesso;
    } catch (erro) {
      mensagemErro =
          mensagemDoErro(erro, 'Não foi possível carregar o catálogo.');
      estado = EstadoTela.erro;
    } finally {
      notifyListeners();
    }
  }

  /// Atualiza só o kit (contador do ícone) ao voltar dos detalhes ou do kit.
  Future<void> atualizarKit() async {
    try {
      kit = await kitRepository.buscar(usuarioId);
      notifyListeners();
    } catch (_) {
      // Mantém o contador anterior se a consulta falhar.
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
