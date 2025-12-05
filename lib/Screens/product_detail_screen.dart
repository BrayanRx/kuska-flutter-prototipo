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
            // 1. IMAGEN DEL PRODUCTO
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
            
            // Rating
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
                  '(120 pedidos)',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. SELECTOR DE CANTIDAD Y AGREGAR AL CARRITO (MOVIDO ARRIBA)
            // Agrupado en un Container para darle énfasis visual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cantidad (kg)',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      // Selector numérico
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _decrementQty,
                              icon: const Icon(Icons.remove, size: 18),
                              color: _kuskaGreen,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _qtyController,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: _setQuantityFromText,
                              ),
                            ),
                            IconButton(
                              onPressed: _incrementQty,
                              icon: const Icon(Icons.add, size: 18),
                              color: _kuskaGreen,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón Agregar y Total
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
                          Text(
                            'S/ ${total.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: _kuskaGreen),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Cart.instance.addProduct(product, _quantityKg);
                              Navigator.of(context).pop();
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Agregaste ${_formatQty(_quantityKg)}kg de ${product.name}'),
                                  backgroundColor: _kuskaGreen,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kuskaGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Agregar al Pedido',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mínimo de compra: ${_formatQty(product.minOrderKg)} kg',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 4. MÓDULO DE PREDICCIÓN DE PRECIOS (KUSKA PREDICT)
            _buildPredictionModule(),
            const SizedBox(height: 24),

            // 5. BARRA S³ (Call to Action)
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

  // --- WIDGET DE PREDICCIÓN DE PRECIOS DINÁMICO ---
  Widget _buildPredictionModule() {
    // 1. Configuración dinámica según la tendencia del producto
    final trend = widget.product.trend;
    
    // Variables por defecto
    List<double> barHeights; 
    String adviceTitle;
    String adviceText;
    Color trendColor;
    IconData trendIcon;
    Color bgAlertColor;
    Color borderAlertColor;

    switch (trend) {
      case PriceTrend.rising:
        // Gráfico ascendente (Escasez)
        barHeights = [0.3, 0.35, 0.4, 0.5, 0.65, 0.8, 0.9];
        adviceTitle = 'Tendencia al Alza (+15%)';
        adviceText = 'Recomendación: Abastecerse hoy. IA detecta escasez hídrica en Huaral impactando la cosecha futura.';
        trendColor = Colors.orange.shade800;
        trendIcon = Icons.trending_up;
        bgAlertColor = Colors.orange.shade50;
        borderAlertColor = Colors.orange.shade100;
        break;

      case PriceTrend.falling:
        // Gráfico descendente (Buena temporada)
        barHeights = [0.9, 0.8, 0.6, 0.5, 0.4, 0.35, 0.3];
        adviceTitle = 'Tendencia a la Baja (-10%)';
        adviceText = 'Recomendación: Comprar lo justo. Entra temporada alta en Tarma, precios bajarán la próxima semana.';
        trendColor = Colors.green.shade800;
        trendIcon = Icons.trending_down;
        bgAlertColor = Colors.green.shade50;
        borderAlertColor = Colors.green.shade100;
        break;

      case PriceTrend.stable:
      default:
        // Gráfico plano (Estabilidad)
        barHeights = [0.45, 0.5, 0.48, 0.5, 0.52, 0.5, 0.5];
        adviceTitle = 'Precio Estable';
        adviceText = 'Recomendación: Mantener stock habitual. La producción en el valle es constante y sin riesgos climáticos.';
        trendColor = Colors.blue.shade800;
        trendIcon = Icons.trending_flat;
        bgAlertColor = Colors.blue.shade50;
        borderAlertColor = Colors.blue.shade100;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Kuska Predict™',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100)
                ),
                child: Text(
                  'IA Beta', 
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Proyección de precio a 4 semanas:',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          
          // GRÁFICO DINÁMICO
          SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Pasado
                _ChartBar(label: '-3 Sem', heightPct: barHeights[0], isPast: true),
                _ChartBar(label: '-2 Sem', heightPct: barHeights[1], isPast: true),
                _ChartBar(label: '-1 Sem', heightPct: barHeights[2], isPast: true),
                
                // Hoy
                _ChartBar(label: 'Hoy', heightPct: barHeights[3], isPast: true, isToday: true),
                
                // Futuro (Predicciones) - Usamos predictionColor
                _ChartBar(label: '+1 Sem', heightPct: barHeights[4], isPrediction: true, predictionColor: trendColor),
                _ChartBar(label: '+2 Sem', heightPct: barHeights[5], isPrediction: true, predictionColor: trendColor),
                _ChartBar(label: '+3 Sem', heightPct: barHeights[6], isPrediction: true, predictionColor: trendColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // INSIGHT DE NEGOCIO DINÁMICO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgAlertColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderAlertColor)
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(trendIcon, size: 18, color: trendColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adviceTitle,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        adviceText,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.black87, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- LÓGICA DEL MODAL S3 ---
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

// --- WIDGET AUXILIAR PARA EL GRÁFICO (ACTUALIZADO CON PARAMETRO COLOR) ---
class _ChartBar extends StatelessWidget {
  final String label;
  final double heightPct;
  final bool isPast;
  final bool isPrediction;
  final bool isToday;
  final Color? predictionColor; 

  const _ChartBar({
    required this.label,
    required this.heightPct,
    this.isPast = false,
    this.isPrediction = false,
    this.isToday = false,
    this.predictionColor,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (isToday) {
      barColor = const Color(0xFF002C28); // Kuska Green
    } else if (isPrediction) {
      // Usamos el color pasado o un fallback naranja
      barColor = predictionColor?.withValues(alpha: 0.6) ?? Colors.orange.shade300; 
    } else {
      barColor = Colors.grey.shade300;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPrediction) 
          Icon(Icons.auto_awesome, size: 8, color: predictionColor ?? Colors.orange),
        
        const SizedBox(height: 4),
        
        // La barra
        AnimatedContainer( 
          duration: const Duration(milliseconds: 500),
          width: 8,
          height: 40 * heightPct, 
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10, 
            color: isToday ? Colors.black : Colors.grey[600],
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ],
    );
  }
}

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
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(999)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002C28).withValues(alpha: 0.05),
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
              const Align(alignment: Alignment.centerLeft, child: Text('Desglose por dimensión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey))),
              const SizedBox(height: 16),
              _DimensionBar(label: 'Ambiental', score: product.envScore, color: const Color(0xFF2E7D32), icon: Icons.eco_outlined),
              const SizedBox(height: 12),
              _DimensionBar(label: 'Social', score: product.socialScore, color: const Color(0xFFD32F2F), icon: Icons.groups_outlined),
              const SizedBox(height: 12),
              _DimensionBar(label: 'Económico', score: product.economicScore, color: const Color(0xFFF9A825), icon: Icons.trending_up),
              const SizedBox(height: 32),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: baseColor[700])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600], height: 1.1), maxLines: 2, overflow: TextOverflow.ellipsis)])),
        ],
      ),
    );
  }
}