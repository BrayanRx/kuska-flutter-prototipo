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

  // Color corporativo
  final Color _kuskaGreen = const Color(0xFF002C28);

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
    // Si es entero, sin decimales; si no, con 1 decimal
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  void _setQuantityFromText(String text) {
    final product = widget.product;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null) {
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
      _quantityKg += 1; 
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
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGEN DEL PRODUCTO (Estabilizada 4:3)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.asset(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // 2. ENCABEZADO (Nombre + Precio)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${product.pricePerKg.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _kuskaGreen,
                      ),
                    ),
                    Text(
                      'por kg',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            
            // Rating pequeño
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Text(
                  '(120 pedidos)', // Mock data
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. BARRA S³ COMPACTA (Call to Action para ver detalle)
            GestureDetector(
              onTap: () => _showS3Modal(context, product),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    // Círculo S3
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _kuskaGreen,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'S³',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info Score
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score de Sostenibilidad',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                          ),
                          Row(
                            children: [
                              Text(
                                '${product.s3Score.toStringAsFixed(1)} / 5.0',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. SELECTOR DE CANTIDAD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad (kg)',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mínimo: ${_formatQty(product.minOrderKg)} kg',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _decrementQty,
                        icon: const Icon(Icons.remove, size: 20),
                        color: _kuskaGreen,
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _qtyController,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          onSubmitted: _setQuantityFromText,
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementQty,
                        icon: const Icon(Icons.add, size: 20),
                        color: _kuskaGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 5. TOTAL Y BOTÓN DE ACCIÓN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total estimado', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    Text(
                      'S/ ${total.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: _kuskaGreen),
                    ),
                  ],
                ),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Cart.instance.addProduct(product, _quantityKg);
                      Navigator.of(context).pop();
                      
                      // Feedback visual opcional
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agregaste ${_formatQty(_quantityKg)}kg de ${product.name}'),
                          backgroundColor: _kuskaGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kuskaGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Agregar',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Producido por Asoc. de Agricultores del Valle\ncon prácticas sostenibles verificadas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500], height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DEL MODAL S3 (DASHBOARD EJECUTIVO) ---

  void _showS3Modal(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return _S3DetailsSheet(product: product);
      },
    );
  }
}

// --- WIDGETS AUXILIARES DEL DASHBOARD S3 ---

class _S3DetailsSheet extends StatelessWidget {
  final Product product;

  const _S3DetailsSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(999)),
              ),

              // Hero Score
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002C28).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('S³', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF002C28))),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.s3Score.toStringAsFixed(1)} / 5.0',
                        style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, height: 1.0, color: Colors.black87),
                      ),
                      Text(
                        _getScoreLabel(product.s3Score),
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _getScoreColor(product.s3Score)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Barras de Dimensión
              const Align(alignment: Alignment.centerLeft, child: Text('Desglose por dimensión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey))),
              const SizedBox(height: 16),
              _DimensionBar(label: 'Ambiental', score: product.envScore, color: const Color(0xFF2E7D32), icon: Icons.eco_outlined),
              const SizedBox(height: 12),
              _DimensionBar(label: 'Social', score: product.socialScore, color: const Color(0xFFD32F2F), icon: Icons.groups_outlined),
              const SizedBox(height: 12),
              _DimensionBar(label: 'Económico', score: product.economicScore, color: const Color(0xFFF9A825), icon: Icons.trending_up),

              const SizedBox(height: 32),

              // KPI Grid
              const Align(alignment: Alignment.centerLeft, child: Text('Métricas de Impacto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey))),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _KpiCard(value: '${product.mermasEvitadas.toStringAsFixed(0)}%', label: 'Mermas evitadas', icon: Icons.delete_outline, color: Colors.green),
                  _KpiCard(value: '${product.pagoDirecto.toStringAsFixed(0)}%', label: 'Pago directo', icon: Icons.handshake_outlined, color: Colors.blue),
                  _KpiCard(value: '${product.co2KgPorKg}kg', label: 'CO₂ / kg', icon: Icons.cloud_outlined, color: Colors.teal),
                  _KpiCard(value: '${product.puntualidad.toStringAsFixed(0)}%', label: 'Puntualidad', icon: Icons.access_time, color: Colors.orange),
                ],
              ),
              
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: const Text('Ver Certificado de Origen'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[800], side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              )
            ],
          ),
        );
      },
    );
  }

  String _getScoreLabel(double score) {
    if (score >= 4.5) return 'Excelente Impacto';
    if (score >= 3.5) return 'Muy Buen Desempeño';
    return 'Desempeño Estándar';
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return const Color(0xFF2E7D32);
    if (score >= 3.0) return const Color(0xFFF9A825);
    return Colors.grey;
  }
}

class _DimensionBar extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  final IconData icon;

  const _DimensionBar({required this.label, required this.score, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final percent = (score / 5.0).clamp(0.0, 1.0);
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey[100], color: color, minHeight: 8))),
        const SizedBox(width: 12),
        Text(score.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final MaterialColor? color;

  const _KpiCard({required this.value, required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: baseColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: baseColor[700])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600], height: 1.1), maxLines: 2, overflow: TextOverflow.ellipsis)])),
        ],
      ),
    );
  }
}