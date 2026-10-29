// O model se chama Material, por isso o widget Material do Flutter é ocultado.
import 'package:flutter/material.dart' hide Material;

import '../core/session/sessao.dart';
import '../core/state/estado_tela.dart';
import '../model/material.dart';
import '../repository/kit_repository.dart';
import '../repository/material_repository.dart';
import '../repository/usuario_repository.dart';
import '../viewmodel/catalogo_viewmodel.dart';
import 'cadastro_material_view.dart';
import 'detalhes_material_view.dart';
import 'kit_view.dart';
import 'login_view.dart';
import 'widgets/componentes.dart';

class CatalogoView extends StatefulWidget {
  final UsuarioRepository usuarioRepository;
  final MaterialRepository materialRepository;
  final KitRepository kitRepository;

  const CatalogoView({
    super.key,
    required this.usuarioRepository,
    required this.materialRepository,
    required this.kitRepository,
  });

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  late final CatalogoViewModel _viewModel;
  // Nome guardado ao abrir a tela (a sessão é limpa ao sair).
  final _nomeUsuario = Sessao.usuario!.nome;
  final _buscaController = TextEditingController();

  // Variáveis locais da tela, alteradas com setState.
  String _busca = '';
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _viewModel = CatalogoViewModel(
      materialRepository: widget.materialRepository,
      kitRepository: widget.kitRepository,
      usuarioId: Sessao.usuarioId,
    );
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _abrirDetalhes(Material material) async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(
      builder: (_) => DetalhesMaterialView(
        materialId: material.id,
        materialRepository: widget.materialRepository,
        kitRepository: widget.kitRepository,
      ),
    ));
    if (mounted) _viewModel.atualizarKit();
  }

  Future<void> _abrirKit() async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(
      builder: (_) => KitView(repository: widget.kitRepository),
    ));
    if (mounted) _viewModel.atualizarKit();
  }

  Future<void> _abrirCadastro() async {
    final cadastrado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            CadastroMaterialView(repository: widget.materialRepository),
      ),
    );
    if (!mounted || cadastrado != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material cadastrado.')),
    );
    setState(() => _categoria = null);
    _viewModel.carregar();
  }

  void _sair() {
    Sessao.sair();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginView(
          usuarioRepository: widget.usuarioRepository,
          materialRepository: widget.materialRepository,
          kitRepository: widget.kitRepository,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catálogo'),
              TextoSecundario('Olá, $_nomeUsuario'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Meu kit',
              onPressed: _abrirKit,
              icon: Badge(
                isLabelVisible: _viewModel.kit.quantidadeTotal > 0,
                label: Text('${_viewModel.kit.quantidadeTotal}'),
                child: const Icon(Icons.shopping_basket_outlined),
              ),
            ),
            IconButton(
              tooltip: 'Sair / trocar de conta',
              onPressed: _sair,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _abrirCadastro,
          icon: const Icon(Icons.add),
          label: const Text('Novo material'),
        ),
        body: switch (_viewModel.estado) {
          EstadoTela.inicial || EstadoTela.carregando =>
            const EstadoCarregando(mensagem: 'Carregando catálogo...'),
          EstadoTela.erro => EstadoErro(
              mensagem: _viewModel.mensagemErro!,
              tentarNovamente: _viewModel.carregar,
            ),
          EstadoTela.sucesso => _catalogo(),
        },
      ),
    );
  }

  Widget _catalogo() {
    final materiais = _viewModel.filtrar(_busca, _categoria);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              hintText: 'Pesquisar por nome',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (valor) => setState(() => _busca = valor),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: _categoria == null,
                onSelected: (_) => setState(() => _categoria = null),
              ),
              for (final categoria in _viewModel.categorias) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(categoria),
                  selected: _categoria == categoria,
                  onSelected: (_) => setState(() => _categoria = categoria),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _viewModel.carregar,
            child: materiais.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 48),
                    TextoSecundario('Nenhum material encontrado.',
                        alinhamento: TextAlign.center),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: materiais.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, indice) => CartaoMaterial(
                      material: materiais[indice],
                      aoTocar: () => _abrirDetalhes(materiais[indice]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
