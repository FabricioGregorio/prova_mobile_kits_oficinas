import 'package:flutter/material.dart';

import '../core/session/sessao.dart';
import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../repository/kit_repository.dart';
import '../repository/material_repository.dart';
import '../viewmodel/detalhes_material_viewmodel.dart';
import 'widgets/componentes.dart';

class DetalhesMaterialView extends StatefulWidget {
  final int materialId;
  final MaterialRepository materialRepository;
  final KitRepository kitRepository;

  const DetalhesMaterialView({
    super.key,
    required this.materialId,
    required this.materialRepository,
    required this.kitRepository,
  });

  @override
  State<DetalhesMaterialView> createState() => _DetalhesMaterialViewState();
}

class _DetalhesMaterialViewState extends State<DetalhesMaterialView> {
  late final DetalhesMaterialViewModel _viewModel;

  // Quantidade escolhida nesta tela (setState). Só vai para o kit ao confirmar.
  int _quantidade = 1;

  @override
  void initState() {
    super.initState();
    _viewModel = DetalhesMaterialViewModel(
      materialRepository: widget.materialRepository,
      kitRepository: widget.kitRepository,
      materialId: widget.materialId,
      usuarioId: Sessao.usuarioId,
    );
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _adicionar() async {
    final adicionado = await _viewModel.adicionarAoKit(_quantidade);
    if (!mounted) return;
    final mensageiro = ScaffoldMessenger.of(context);
    mensageiro.hideCurrentSnackBar();
    if (adicionado) {
      mensageiro.showSnackBar(SnackBar(
          content: Text(
              '$_quantidade × ${_viewModel.material!.nome} adicionado ao kit.')));
      Navigator.of(context).pop();
    } else {
      mensageiro.showSnackBar(SnackBar(
        content: Text(_viewModel.erroAcao!),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Detalhes')),
          body: switch (_viewModel.estado) {
            EstadoTela.inicial || EstadoTela.carregando =>
              const EstadoCarregando(mensagem: 'Carregando material...'),
            EstadoTela.erro => EstadoErro(
                mensagem: _viewModel.mensagemErro!,
                tentarNovamente: _viewModel.carregar,
              ),
            EstadoTela.sucesso => _detalhes(),
          },
        ),
      );

  Widget _detalhes() {
    final material = _viewModel.material!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              material.imagemUrl,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: const Color(0xffe6f2f0),
                child: const Icon(Icons.inventory_2_outlined,
                    size: 64, color: corPrimaria),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextoTitulo(material.nome),
          const SizedBox(height: 4),
          TextoSecundario(material.categoria),
          const SizedBox(height: 12),
          Text(material.descricao, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Row(children: [
            const TextoSecundario('Preço unitário: '),
            TextoPreco(material.preco),
          ]),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SeletorQuantidade(
                quantidade: _quantidade,
                habilitado: !_viewModel.adicionando,
                aoAlterar: (valor) => setState(() => _quantidade = valor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextoSecundario(
                      '${formatarPreco(material.preco)} × $_quantidade'),
                  TextoPreco(material.preco * _quantidade, tamanho: 22),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _viewModel.adicionando ? null : _adicionar,
            icon: _viewModel.adicionando
                ? const SizedBox.shrink()
                : const Icon(Icons.add_shopping_cart),
            label: _viewModel.adicionando
                ? const RotuloEnvio(texto: 'Adicionando...')
                : const Text('Adicionar ao kit'),
          ),
        ],
      ),
    );
  }
}
