import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuska_prototipos/cart.dart';
import 'package:kuska_prototipos/product.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final shortId = 'PED-${order.id.substring(order.id.length - 4)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Detalle de pedido',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shortId,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // A. TIMELINE LOGÍSTICO
            _SectionTitle('Estado logístico'),
            const SizedBox(height: 8),
            _StatusTimeline(status: order.status),
            const SizedBox(height: 20),

            // B. PROMESA DE ENTREGA
            _SectionTitle('Promesa de entrega'),
            const SizedBox(height: 8),
            _DeliveryMemory(order: order),
            const SizedBox(height: 20),

            // C. PRODUCTOS CON TRAZABILIDAD
            _SectionTitle('Productos y trazabilidad'),
            const SizedBox(height: 8),
            _ProductsTrace(order: order),
            const SizedBox(height: 20),

            // D. BLOQUE FINANCIERO / FISCAL
            _SectionTitle('Resumen financiero y fiscal'),
            const SizedBox(height: 8),
            _FinancialBlock(order: order),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ----------------------------------------------------------------------
// A. TIMELINE LOGÍSTICO
// ----------------------------------------------------------------------

class _StatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const _StatusTimeline({required this.status});

  int get _currentIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.inHub:
        return 2;
      case OrderStatus.onRoute:
        return 3;
      case OrderStatus.delivered:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Recibido',
      'En acopio',
      'En ruta',
      'Entregado',
    ];

    final current = _currentIndex.clamp(0, 4);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index <= current - 1;
              final isCurrent = index == current - 1;

              final circleColor = isActive
                  ? const Color(0xFF00A67A)
                  : Colors.grey.shade300;

              final inner = Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: isActive
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              );

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index <= current - 1
                                  ? const Color(0xFF00A67A)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        inner,
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index < current - 1
                                  ? const Color(0xFF00A67A)
                                  : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// B. PROMESA DE ENTREGA
// ----------------------------------------------------------------------

class _DeliveryMemory extends StatelessWidget {
  final Order order;

  const _DeliveryMemory({required this.order});

  @override
  Widget build(BuildContext context) {
    final arrival = _formatArrival(order.deliveryStart, order.deliveryEnd);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tu entrega está programada para\n$arrival',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F6F1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              order.deliveryWindowLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF005B4A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// C. PRODUCTOS CON TRAZABILIDAD
// ----------------------------------------------------------------------

class _ProductsTrace extends StatelessWidget {
  final Order order;

  const _ProductsTrace({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final item in order.items) ...[
            _TraceItem(
              item: item,
              createdAt: order.createdAt,
            ),
            const SizedBox(height: 10),
            if (item != order.items.last)
              const Divider(height: 16),
          ],
        ],
      ),
    );
  }
}

class _TraceItem extends StatelessWidget {
  final CartItem item;
  final DateTime createdAt;

  const _TraceItem({
    required this.item,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    final origin = _originFor(product);
    final batchId = _batchFor(product, createdAt);
    final harvestLabel = _harvestLabel(createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            product.imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.quantityKg.toStringAsFixed(1)} kg · '
                'S/ ${product.pricePerKg.toStringAsFixed(2)} / kg',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                origin,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Lote: $batchId',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Cosechado: $harvestLabel',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Helpers de trazabilidad mock
String _originFor(Product p) {
  if (p.name.toLowerCase().contains('papa')) {
    return 'Valle de Huaral · Asoc. Agricultores Andinos';
  }
  if (p.name.toLowerCase().contains('ají')) {
    return 'Valle de Cañete · Cooperativa Ají Amarillo';
  }
  if (p.name.toLowerCase().contains('cebolla')) {
    return 'Valle de Ica · Red de Hortalizas';
  }
  return 'Red de Productores Kuska';
}

String _batchFor(Product p, DateTime createdAt) {
  final y = createdAt.year.toString().substring(2);
  final m = _twoDigits(createdAt.month);
  final d = _twoDigits(createdAt.day);
  return 'L-$y$m$d-${p.name.codeUnitAt(0)}';
}

String _harvestLabel(DateTime createdAt) {
  // Para demo: la cosecha fue 2 días antes del pedido
  final harvest = createdAt.subtract(const Duration(days: 2));
  final day = _twoDigits(harvest.day);
  final month = _twoDigits(harvest.month);
  final year = harvest.year.toString().substring(2);
  return '$day/$month/$year';
}

// ----------------------------------------------------------------------
// D. BLOQUE FINANCIERO / FISCAL
// ----------------------------------------------------------------------

class _FinancialBlock extends StatelessWidget {
  final Order order;

  const _FinancialBlock({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal productos', value: order.subtotal),
          _PriceRow(label: 'Fee logístico (10%)', value: order.shippingFee),
          const Divider(height: 20),
          _PriceRow(
            label: 'Base imponible',
            value: order.taxableBase,
          ),
          _PriceRow(
            label: 'IGV 18%',
            value: order.igv,
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Total',
            value: order.total,
            isBold: true,
            highlight: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Descarga de PDF simulada (SUNAT).'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: const Text(
                    'Descargar PDF',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Descarga de XML simulada (SUNAT).'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.code_outlined, size: 18),
                  label: const Text(
                    'Descargar XML',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: highlight ? const Color(0xFF002C28) : Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('S/ ${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}

// Utilidades compartidas

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _formatArrival(DateTime start, DateTime end) {
  const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Oct',
    'Nov',
    'Dic'
  ];

  final w = weekdays[start.weekday - 1];
  final m = months[start.month - 1];
  final day = start.day;

  final startH = _twoDigits(start.hour);
  final startM = _twoDigits(start.minute);
  final endH = _twoDigits(end.hour);
  final endM = _twoDigits(end.minute);

  return '$w $day $m en ventana $startH:$startM - $endH:$endM';
}
