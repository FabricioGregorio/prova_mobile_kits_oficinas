import 'package:flutter/material.dart';

import 'core/network/cliente_api.dart';
import 'core/theme/tema_app.dart';
import 'repository/kit_repository.dart';
import 'repository/material_repository.dart';
import 'repository/usuario_repository.dart';
import 'view/login_view.dart';

class KitsApp extends StatefulWidget {
  const KitsApp({super.key});

  @override
  State<KitsApp> createState() => _KitsAppState();
}

class _KitsAppState extends State<KitsApp> {
  late final ClienteApi _clienteApi;
  late final UsuarioRepository _usuarioRepository;
  late final MaterialRepository _materialRepository;
  late final KitRepository _kitRepository;

  @override
  void initState() {
    super.initState();
    _clienteApi = ClienteApi();
    _usuarioRepository = UsuarioRepository(_clienteApi);
    _materialRepository = MaterialRepository(_clienteApi);
    _kitRepository = KitRepository(_clienteApi);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kits para Oficinas',
      theme: temaApp,
      home: LoginView(
        usuarioRepository: _usuarioRepository,
        materialRepository: _materialRepository,
        kitRepository: _kitRepository,
      ),
    );
  }
}
