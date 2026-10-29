import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../repository/kit_repository.dart';
import '../repository/material_repository.dart';
import '../repository/usuario_repository.dart';
import '../viewmodel/login_viewmodel.dart';
import 'cadastro_usuario_view.dart';
import 'catalogo_view.dart';
import 'widgets/componentes.dart';

class LoginView extends StatefulWidget {
  final UsuarioRepository usuarioRepository;
  final MaterialRepository materialRepository;
  final KitRepository kitRepository;

  const LoginView({
    super.key,
    required this.usuarioRepository,
    required this.materialRepository,
    required this.kitRepository,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  late final LoginViewModel _viewModel;

  bool get _enviando => _viewModel.estado == EstadoTela.carregando;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(repository: widget.usuarioRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    final entrou =
        await _viewModel.entrar(_emailController.text, _senhaController.text);
    if (!mounted || !entrou) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => CatalogoView(
        usuarioRepository: widget.usuarioRepository,
        materialRepository: widget.materialRepository,
        kitRepository: widget.kitRepository,
      ),
    ));
  }

  Future<void> _abrirCadastro() async {
    final email = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            CadastroUsuarioView(repository: widget.usuarioRepository),
      ),
    );
    if (!mounted || email == null) return;
    // Conta criada: preenche o e-mail para facilitar o login.
    setState(() {
      _emailController.text = email;
      _senhaController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada. Entre com sua senha.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.inventory_2_rounded,
                        size: 64, color: corPrimaria),
                    const SizedBox(height: 12),
                    const Center(child: TextoTitulo('Kits para Oficinas')),
                    const SizedBox(height: 4),
                    const Center(
                        child: TextoSecundario('Entre para montar seu kit.')),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_enviando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (valor) => valor == null || valor.trim().isEmpty
                          ? 'Informe seu e-mail.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      enabled: !_enviando,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      onFieldSubmitted: (_) => _entrar(),
                      validator: (valor) => valor == null || valor.isEmpty
                          ? 'Informe sua senha.'
                          : null,
                    ),
                    if (_viewModel.estado == EstadoTela.erro) ...[
                      const SizedBox(height: 16),
                      MensagemErro(_viewModel.mensagemErro!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _enviando ? null : _entrar,
                      child: _enviando
                          ? const RotuloEnvio(texto: 'Entrando...')
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _enviando ? null : _abrirCadastro,
                      child: const Text('Não tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
