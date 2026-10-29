import 'package:dio/dio.dart';

/// Converte o erro de uma requisição em uma mensagem para o usuário.
String mensagemDoErro(Object erro, String mensagemPadrao) {
  if (erro is! DioException) return mensagemPadrao;
  if (erro.response != null) {
    final dados = erro.response?.data;
    if (dados is Map && dados['message'] is String) {
      return dados['message'] as String;
    }
    return 'Não foi possível concluir a solicitação. Tente novamente.';
  }
  if (erro.type == DioExceptionType.connectionTimeout ||
      erro.type == DioExceptionType.receiveTimeout ||
      erro.type == DioExceptionType.sendTimeout) {
    return 'A API demorou para responder. Tente novamente.';
  }
  return 'Não foi possível conectar à API. Tente novamente.';
}

/// Lê os erros por campo enviados pela API (ex.: {"erros": {"nome": "..."}}).
Map<String, String> errosDosCampos(Object erro) {
  final erros = <String, String>{};
  if (erro is DioException) {
    final dados = erro.response?.data;
    if (dados is Map && dados['erros'] is Map) {
      final errosApi = dados['erros'] as Map;
      for (final campo in errosApi.keys) {
        final mensagem = errosApi[campo];
        if (campo is String && mensagem is String) erros[campo] = mensagem;
      }
    }
  }
  return erros;
}
