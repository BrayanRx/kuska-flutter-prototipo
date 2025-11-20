import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuska_prototipos/product.dart';
import 'package:kuska_prototipos/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late double _quantityKg;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _quantityKg = widget.product.minOrderKg;
    _qtyController = TextEditingController(text: _formatQty(_quantityKg));
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  String _formatQty(double value) {
    // si es entero, muéstralo sin decimales; si no, con 1 decimal
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  void _setQuantityFromText(String text) {
    final product = widget.product;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null) {
      // si mete basura, volvemos al mínimo
      setState(() {
        _quantityKg = product.minOrderKg;
        _qtyController.text = _formatQty(_quantityKg);
      });
      return;
    }

    double newQty = parsed;
    if (newQty < product.minOrderKg) {
      newQty = product.minOrderKg;
    }

    setState(() {
      _quantityKg = newQty;
      _qtyController.value = _qtyController.value.copyWith(
        text: _formatQty(_quantityKg),
        selection: TextSelection.collapsed(
          offset: _formatQty(_quantityKg).length,
        ),
      );
    });
  }

  void _incrementQty() {
    setState(() {
      _quantityKg += 1; // paso de 1 kg; si quieres, cámbialo a 5
      _qtyController.text = _formatQty(_quantityKg);
    });
  }

  void _decrementQty() {
    final min = widget.product.minOrderKg;
    setState(() {
      _quantityKg = (_quantityKg - 1).clamp(min, double.infinity);
      _qtyController.text = _formatQty(_quantityKg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final total = product.pricePerKg * _quantityKg;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen grande del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.asset(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre + precio por kg
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'S/ ${product.pricePerKg.toStringAsFixed(2)} x kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // S³ compacto
            GestureDetector(
              onTap: () {
                _showS3Modal(context, product);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _S3Circle(),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.s3Score.toStringAsFixed(1)} / 5',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Toca para ver el detalle S³',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cantidad editable + mínimo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cantidad (kg)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mínimo: ${_formatQty(product.minOrderKg)} kg',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _decrementQty,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _qtyController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _setQuantityFromText,
                        onChanged: (value) {
                          // No forzamos en cada tecla, validamos al terminar (onSubmitted).
                          // Puedes comentar esto si molesta.
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _incrementQty,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Total: S/ ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Botón Añadir a la canasta (luego lo conectamos al carrito real)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí, en el siguiente paso, usaremos Cart para guardar el pedido
                  final product = widget.product;

                  // 1. Añadir al carrito en memoria
                  Cart.instance.addProduct(product, _quantityKg);

                  Navigator.of(context).pop();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002C28),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Añadir a la canasta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Producido por agricultores locales con prácticas sostenibles, '
              'integrados a la red Kuska para mejorar su S³ en cada campaña.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _S3Circle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF004D40),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'S³',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}

// El modal S³ se queda igual que antes
void _showS3Modal(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _S3Circle(),
                      const SizedBox(width: 16),
                      Text(
                        '${product.s3Score.toStringAsFixed(1)} / 5',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Este score resume el desempeño del productor en tres dimensiones: '
                    'ambiental, social y económica.',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  _S3DimensionCard(
                    title: 'Ambiental',
                    emoji: '🌿',
                    titleColor: const Color(0xFF2E7D32),
                    description:
                        'Impacto ambiental y eficiencia operativa en la cadena.',
                    metrics: [
                      '${product.mermasEvitadas.toStringAsFixed(0)}% - Mermas evitadas',
                      '${product.co2KgPorKg.toStringAsFixed(1)} kg - CO₂ por kg transportado',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _S3DimensionCard(
                    title: 'Social',
                    emoji: '👥',
                    titleColor: const Color(0xFFD32F2F),
                    description:
                        'Beneficios al productor y prácticas comerciales responsables.',
                    metrics: [
                      '${product.pagoDirecto.toStringAsFixed(0)}% - % de pago directo',
                      '${product.tiempoPromedioPago.toStringAsFixed(0)} h - Tiempo promedio de pago',
                      '<${product.tiempoEntrega.toStringAsFixed(0)} h - Tiempo de entrega',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _S3DimensionCard(
                    title: 'Económico',
                    emoji: '💰',
                    titleColor: const Color(0xFFF9A825),
                    description:
                        'Estabilidad y confiabilidad de la relación comercial.',
                    metrics: [
                      '${product.puntualidad.toStringAsFixed(0)}% - puntualidad en entregas',
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _S3DimensionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color titleColor;
  final String description;
  final List<String> metrics;

  const _S3DimensionCard({
    required this.title,
    required this.emoji,
    required this.titleColor,
    required this.description,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '$emoji '),
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          for (final m in metrics) ...[
            Text(
              m,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
