// O model se chama Material, por isso o widget Material do Flutter é ocultado.
import 'package:flutter/material.dart' hide Material;

import '../../core/theme/tema_app.dart';
import '../../model/material.dart';

String formatarPreco(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

// ---------------------------------------------------------------------------
// Textos padronizados
// ---------------------------------------------------------------------------

class TextoTitulo extends StatelessWidget {
  final String texto;

  const TextoTitulo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: corEscura),
      );
}

class TextoSecundario extends StatelessWidget {
  final String texto;
  final TextAlign? alinhamento;

  const TextoSecundario(this.texto, {super.key, this.alinhamento});

  @override
  Widget build(BuildContext context) => Text(
        texto,
        textAlign: alinhamento,
        style: const TextStyle(fontSize: 14, color: corTextoSecundario),
      );
}

class TextoPreco extends StatelessWidget {
  final double valor;
  final double tamanho;

  const TextoPreco(this.valor, {super.key, this.tamanho = 16});

  @override
  Widget build(BuildContext context) => Text(
        formatarPreco(valor),
        style: TextStyle(
            fontSize: tamanho, fontWeight: FontWeight.w800, color: corPrimaria),
      );
}

// ---------------------------------------------------------------------------
// Imagem e cartão de material
// ---------------------------------------------------------------------------

class ImagemMaterial extends StatelessWidget {
  final String url;
  final double largura;
  final double altura;

  const ImagemMaterial(
      {super.key, required this.url, this.largura = 72, this.altura = 72});

  @override
  Widget build(BuildContext context) {
    final semImagem = Container(
      width: largura,
      height: altura,
      color: const Color(0xffe6f2f0),
      child: const Icon(Icons.inventory_2_outlined, color: corPrimaria),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url.isEmpty
          ? semImagem
          : Image.network(
              url,
              width: largura,
              height: altura,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => semImagem,
            ),
    );
  }
}

/// Apresenta um material. Usado no catálogo e no kit; o kit passa uma
/// [acao] (botão de remoção) e um [rodape] (seletor de quantidade e subtotal).
class CartaoMaterial extends StatelessWidget {
  final Material material;
  final VoidCallback? aoTocar;
  final Widget? acao;
  final Widget? rodape;

  const CartaoMaterial({
    super.key,
    required this.material,
    this.aoTocar,
    this.acao,
    this.rodape,
  });

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImagemMaterial(url: material.imagemUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(material.nome,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: corEscura)),
                          const SizedBox(height: 2),
                          TextoSecundario(material.categoria),
                          const SizedBox(height: 6),
                          TextoPreco(material.preco),
                        ],
                      ),
                    ),
                    if (acao != null) acao!,
                  ],
                ),
                if (rodape != null) ...[
                  const SizedBox(height: 10),
                  rodape!,
                ],
              ],
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Botões e seletor
// ---------------------------------------------------------------------------

class BotaoRemover extends StatelessWidget {
  final VoidCallback? aoPressionar;
  final String dica;

  const BotaoRemover(
      {super.key, required this.aoPressionar, this.dica = 'Remover'});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: dica,
        onPressed: aoPressionar,
        color: Theme.of(context).colorScheme.error,
        icon: const Icon(Icons.delete_outline),
      );
}

/// Seletor de quantidade entre [minimo] e [maximo]. Quem usa decide o que
/// fazer com o novo valor em [aoAlterar] (setState nos detalhes, PATCH no kit).
class SeletorQuantidade extends StatelessWidget {
  final int quantidade;
  final ValueChanged<int> aoAlterar;
  final int minimo;
  final int maximo;
  final bool habilitado;

  const SeletorQuantidade({
    super.key,
    required this.quantidade,
    required this.aoAlterar,
    this.minimo = 1,
    this.maximo = 99,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xffe6f2f0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Diminuir',
              onPressed: habilitado && quantidade > minimo
                  ? () => aoAlterar(quantidade - 1)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 32,
              child: Text('$quantidade',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            IconButton(
              tooltip: 'Aumentar',
              onPressed: habilitado && quantidade < maximo
                  ? () => aoAlterar(quantidade + 1)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Estados de tela
// ---------------------------------------------------------------------------

class EstadoCarregando extends StatelessWidget {
  final String mensagem;

  const EstadoCarregando({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          TextoSecundario(mensagem),
        ]),
      );
}

class EstadoErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback tentarNovamente;

  const EstadoErro(
      {super.key, required this.mensagem, required this.tentarNovamente});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 56, color: corPrimaria),
            const SizedBox(height: 16),
            TextoSecundario(mensagem, alinhamento: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: tentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ]),
        ),
      );
}

class MensagemErro extends StatelessWidget {
  final String mensagem;

  const MensagemErro(this.mensagem, {super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cores.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(mensagem, style: TextStyle(color: cores.onErrorContainer)),
    );
  }
}

class RotuloEnvio extends StatelessWidget {
  final String texto;

  const RotuloEnvio({super.key, required this.texto});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary)),
          const SizedBox(width: 10),
          Text(texto),
        ],
      );
}
