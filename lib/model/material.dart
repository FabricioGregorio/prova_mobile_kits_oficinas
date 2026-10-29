// Atenção: o nome "Material" também existe no Flutter. Nas views este arquivo
// é importado junto com `import 'package:flutter/material.dart' hide Material;`.
class Material {
  final int id;
  final String nome;
  final String descricao;
  final String categoria;
  final double preco;
  final String imagemUrl;

  const Material({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.preco,
    required this.imagemUrl,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as String,
      preco: (json['preco'] as num).toDouble(),
      imagemUrl: (json['imagemUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'categoria': categoria,
        'preco': preco,
        'imagemUrl': imagemUrl,
      };
}
