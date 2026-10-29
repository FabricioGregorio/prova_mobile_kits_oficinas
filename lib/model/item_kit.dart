import 'material.dart';

class ItemKit {
  final Material material;
  final int quantidade;
  final double subtotal;

  const ItemKit({
    required this.material,
    required this.quantidade,
    required this.subtotal,
  });

  factory ItemKit.fromJson(Map<String, dynamic> json) {
    return ItemKit(
      material: Material.fromJson(json['material'] as Map<String, dynamic>),
      quantidade: (json['quantidade'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'material': material.toJson(),
        'quantidade': quantidade,
        'subtotal': subtotal,
      };
}
