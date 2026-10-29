import 'package:flutter/material.dart';

import '../core/session/sessao.dart';
import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../model/item_kit.dart';
import '../repository/kit_repository.dart';
import '../viewmodel/kit_viewmodel.dart';
import 'widgets/componentes.dart';

class KitView extends StatefulWidget {
  final KitRepository repository;

  const KitView({super.key, required this.repository});

  @override
  State<KitView> createState() => _KitViewState();
}

class _KitViewState extends State<KitView> {
  late final KitViewModel _viewModel;
  // Nome guardado ao abrir a tela (a sessão é limpa ao sair).
  final _nomeUsuario = Sessao.usuario!.nome;

  @override
  void initState() {
    super.initState();
    // O usuário conectado determina qual kit é consultado.
    _viewModel =
        KitViewModel(repository: widget.repository, usuarioId: Sessao.usuarioId);
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _mostrarResultado(bool sucesso, String mensagemSucesso) {
    if (!mounted) return;
    final mensageiro = ScaffoldMessenger.of(context);
    mensageiro.hideCurrentSnackBar();
    mensageiro.showSnackBar(SnackBar(
      content: Text(sucesso ? mensagemSucesso : _viewModel.erroAcao!),
      backgroundColor: sucesso ? null : Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _alterarQuantidade(ItemKit item, int quantidade) async {
    final ok =
        await _viewModel.alterarQuantidade(item.material.id, quantidade);
    _mostrarResultado(ok, 'Quantidade atualizada.');
  }

  Future<void> _remover(ItemKit item) async {
    final ok = await _viewModel.remover(item.material.id);
    _mostrarResultado(ok, '${item.material.nome} removido do kit.');
  }

  Future<void> _limpar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar kit?'),
        content: const Text('Todos os materiais serão removidos do seu kit.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpar')),
        ],
      ),
    );
    if (confirmar != true) return;
    final ok = await _viewModel.limpar();
    _mostrarResultado(ok, 'Kit limpo.');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Text('Kit de $_nomeUsuario'),
            actions: [
              if (_viewModel.estado == EstadoTela.sucesso &&
                  _viewModel.kit.itens.isNotEmpty)
                TextButton.icon(
                  onPressed: _viewModel.atualizando ? null : _limpar,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Limpar'),
                ),
            ],
          ),
          body: switch (_viewModel.estado) {
            EstadoTela.inicial || EstadoTela.carregando =>
              const EstadoCarregando(mensagem: 'Carregando seu kit...'),
            EstadoTela.erro => EstadoErro(
                mensagem: _viewModel.mensagemErro!,
                tentarNovamente: _viewModel.carregar,
              ),
            EstadoTela.sucesso =>
              _viewModel.kit.itens.isEmpty ? _kitVazio() : _kit(),
          },
        ),
      );

  Widget _kitVazio() => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_basket_outlined, size: 72, color: corPrimaria),
            SizedBox(height: 16),
            TextoTitulo('Seu kit está vazio'),
            SizedBox(height: 8),
            TextoSecundario('Escolha materiais no catálogo para montar o kit.',
                alinhamento: TextAlign.center),
          ]),
        ),
      );

  Widget _kit() => Column(
        children: [
          if (_viewModel.atualizando) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _viewModel.kit.itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, indice) {
                final item = _viewModel.kit.itens[indice];
                return CartaoMaterial(
                  material: item.material,
                  acao: BotaoRemover(
                    dica: 'Remover ${item.material.nome}',
                    aoPressionar:
                        _viewModel.atualizando ? null : () => _remover(item),
                  ),
                  rodape: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SeletorQuantidade(
                        quantidade: item.quantidade,
                        habilitado: !_viewModel.atualizando,
                        aoAlterar: (valor) => _alterarQuantidade(item, valor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const TextoSecundario('Subtotal'),
                          TextoPreco(item.subtotal, tamanho: 18),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _resumo(),
        ],
      );

  Widget _resumo() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: corBorda)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextoSecundario('Unidades'),
                  Text('${_viewModel.kit.quantidadeTotal}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  TextoPreco(_viewModel.kit.total, tamanho: 24),
                ],
              ),
            ],
          ),
        ),
      );
}
