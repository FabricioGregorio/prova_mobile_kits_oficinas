import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../repository/usuario_repository.dart';
import '../viewmodel/cadastro_usuario_viewmodel.dart';
import 'widgets/componentes.dart';

class CadastroUsuarioView extends StatefulWidget {
  final UsuarioRepository repository;

  const CadastroUsuarioView({super.key, required this.repository});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  late final CadastroUsuarioViewModel _viewModel;

  bool get _enviando => _viewModel.estado == EstadoTela.carregando;

  @override
  void initState() {
    super.initState();
    _viewModel = CadastroUsuarioViewModel(repository: widget.repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final cadastrado = await _viewModel.cadastrar(
      nome: _nomeController.text.trim(),
      email: email,
      senha: _senhaController.text,
    );
    if (!mounted || !cadastrado) return;
    // Devolve o e-mail para a tela de login.
    Navigator.of(context).pop(email);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Criar conta')),
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
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      errorText: _viewModel.erros['nome'],
                    ),
                    validator: (valor) => valor == null || valor.trim().isEmpty
                        ? 'Informe seu nome.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_enviando,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      errorText: _viewModel.erros['email'],
                    ),
                    validator: (valor) =>
                        valor == null || !valor.contains('@')
                            ? 'Informe um e-mail válido.'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    enabled: !_enviando,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      errorText: _viewModel.erros['senha'],
                    ),
                    onFieldSubmitted: (_) => _salvar(),
                    validator: (valor) => valor == null || valor.length < 6
                        ? 'A senha precisa ter pelo menos 6 caracteres.'
                        : null,
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
                        : const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
