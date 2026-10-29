import '../../model/usuario.dart';

/// Guarda o usuário que fez login. O id dele define qual kit é consultado.
class Sessao {
  static Usuario? usuario;

  static int get usuarioId => usuario!.id;

  static void sair() => usuario = null;
}
