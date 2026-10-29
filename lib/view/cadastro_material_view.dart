import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../repository/material_repository.dart';
import '../viewmodel/cadastro_material_viewmodel.dart';
import 'widgets/componentes.dart';

class CadastroMaterialView extends StatefulWidget {
  final MaterialRepository repository;

  const CadastroMaterialView({super.key, required this.repository});

  @override
  State<CadastroMaterialView> createState() => _CadastroMaterialViewState();
}

class _CadastroMaterialViewState extends State<CadastroMaterialView> {
  final _formKey = GlobalKey<FormState>();
  // Os controllers mantêm o que foi digitado se a requisição falhar.
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precoController = TextEditingController();
  final _imagemController = TextEditingController();
  late final CadastroMaterialViewModel _viewModel;

  bool get _enviando => _viewModel.estado == EstadoTela.carregando;

  @override
  void initState() {
    super.initState();
    _viewModel = CadastroMaterialViewModel(repository: widget.repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  double? _lerPreco(String? valor) =>
      double.tryParse((valor ?? '').trim().replaceAll(',', '.'));

  String? _obrigatorio(String? valor, String mensagem) =>
      valor == null || valor.trim().isEmpty ? mensagem : null;

  Future<void> _salvar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    final cadastrado = await _viewModel.cadastrar(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaController.text.trim(),
      preco: _lerPreco(_precoController.text)!,
      imagemUrl: _imagemController.text.trim(),
    );
    if (!mounted || !cadastrado) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Novo material')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    enabled: !_enviando,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      errorText: _viewModel.erros['nome'],
                    ),
                    validator: (v) => _obrigatorio(v, 'Informe o nome.'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoController,
                    enabled: !_enviando,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      alignLabelWithHint: true,
                      errorText: _viewModel.erros['descricao'],
                    ),
                    validator: (v) => _obrigatorio(v, 'Informe a descrição.'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoriaController,
                    enabled: !_enviando,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      hintText: 'Ex.: Escrita, Papelaria',
                      errorText: _viewModel.erros['categoria'],
                    ),
                    validator: (v) => _obrigatorio(v, 'Informe a categoria.'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precoController,
                    enabled: !_enviando,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Preço (R\$)',
                      hintText: '2,50',
                      errorText: _viewModel.erros['preco'],
                    ),
                    validator: (valor) {
                      final preco = _lerPreco(valor);
                      if (preco == null || !preco.isFinite || preco <= 0) {
                        return 'Informe um preço maior que zero.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imagemController,
                    enabled: !_enviando,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'URL da imagem (opcional)',
                      helperText: 'Em branco, a API usa a imagem padrão.',
                      errorText: _viewModel.erros['imagemUrl'],
                    ),
                    validator: (valor) {
                      final url = (valor ?? '').trim();
                      if (url.isEmpty) return null;
                      final uri = Uri.tryParse(url);
                      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                        return 'Informe uma URL válida (http://...).';
                      }
                      return null;
                    },
                  ),
                  if (_viewModel.estado == EstadoTela.erro) ...[
                    const SizedBox(height: 16),
                    MensagemErro(_viewModel.mensagemErro!),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _enviando ? null : _salvar,
                    child: _enviando
                        ? const RotuloEnvio(texto: 'Cadastrando...')
                        : const Text('Cadastrar material'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
