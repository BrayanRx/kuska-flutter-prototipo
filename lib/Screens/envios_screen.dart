// lib/screens/envios_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kuska_prototipos/cart.dart';

class EnviosScreen extends StatelessWidget {
  const EnviosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Cart.instance.orders;

    if (orders.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Text(
              'Aún no tienes envíos.\nConfirma un pedido desde la canasta.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título Kuska (identidad)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Kuska',
                style: GoogleFonts.libreBaskerville(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tablero de envíos',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Lista de pedidos
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderCard(
                    order: order,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de pedido estilo “tablero”
class _OrderCard extends StatelessWidget {
  final Order order;
  final int index;

  const _OrderCard({
    required this.order,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final totalKg = order.items.fold<double>(
      0,
      (sum, item) => sum + item.quantityKg,
    );
    final productsCount = order.items.length;

    // Info de llegada “futura” simulada a partir del índice
    final deliveryInfo = _computeDeliveryInfo(index);

    final createdAtText = _formatShortDate(order.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: ID + badge de estado
            Row(
              children: [
                Text(
                  _formatOrderId(order.id),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 10),

            // Llega: fecha + ventana horaria
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Llega: ${deliveryInfo.dateLabel}, ${deliveryInfo.slotRange}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Peso total + número de productos
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${totalKg.toStringAsFixed(1)} kg · $productsCount productos',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Total S/.
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  'S/ ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 16),

            // Fila inferior: fecha de pedido + Ver detalle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido el: $createdAtText',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Aquí podrías navegar a una pantalla de detalle
                    // por ahora solo mostramos un mock
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) =>
                          _OrderDetailBottomSheet(order: order, info: deliveryInfo),
                    );
                  },
                  child: const Text('Ver detalle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de estado con colores semánticos
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (status) {
      case OrderStatus.confirmed:
        label = 'Confirmado';
        bg = const Color(0xFFE5F6F1);
        fg = const Color(0xFF00A67A); // Kuska green
        break;
      case OrderStatus.delivered:
        label = 'Entregado';
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// Info de llegada simulada (hoy / mañana, slot horario)
class _DeliveryInfo {
  final DateTime date;
  final String dateLabel; // "Jue 27 Nov"
  final String slotRange; // "08:00 - 10:00"

  _DeliveryInfo({
    required this.date,
    required this.dateLabel,
    required this.slotRange,
  });
}

/// Para el prototipo: generamos ventanas en función del índice
/// alternando entre HOY / MAÑANA y los 3 slots (early, pre-service, afternoon).
_DeliveryInfo _computeDeliveryInfo(int index) {
  final now = DateTime.now();
  final baseDay = DateTime(now.year, now.month, now.day);

  // 0 -> hoy, 1 -> mañana
  final dayOffset = index % 2;
  final date = baseDay.add(Duration(days: dayOffset));

  // 0,1,2 -> early / pre-service / afternoon
  final slotIndex = index % 3;
  late String slotRange;
  switch (slotIndex) {
    case 0:
      slotRange = '05:00 - 07:00 (Early Bird)';
      break;
    case 1:
      slotRange = '08:00 - 10:00 (Pre-Service)';
      break;
    default:
      slotRange = '14:00 - 16:00 (Afternoon)';
      break;
  }

  final dateLabel = _formatDeliveryDate(date);
  return _DeliveryInfo(date: date, dateLabel: dateLabel, slotRange: slotRange);
}

/// Formatea algo como "Jue 27 Nov"
String _formatDeliveryDate(DateTime date) {
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
    'Sep',
    'Oct',
    'Nov',
    'Dic'
  ];

  final wd = weekdays[date.weekday - 1];
  final m = months[date.month - 1];
  final d = date.day.toString().padLeft(2, '0');
  return '$wd $d $m';
}

/// Fecha corta tipo "26/11/25"
String _formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = (date.year % 100).toString().padLeft(2, '0');
  return '$day/$month/$year';
}

/// Formatea el ID con prefijo PED-
String _formatOrderId(String rawId) {
  // Tomamos los últimos 4 dígitos para algo tipo PED-6432
  final suffix = rawId.length <= 4 ? rawId : rawId.substring(rawId.length - 4);
  return 'PED-$suffix';
}

/// BottomSheet simple de detalle de pedido
class _OrderDetailBottomSheet extends StatelessWidget {
  final Order order;
  final _DeliveryInfo info;

  const _OrderDetailBottomSheet({
    required this.order,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final totalKg = order.items.fold<double>(
      0,
      (sum, item) => sum + item.quantityKg,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            _formatOrderId(order.id),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Llega: ${info.dateLabel}, ${info.slotRange}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalKg.toStringAsFixed(1)} kg · ${order.items.length} productos',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Detalle de productos',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in order.items) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name} (${item.quantityKg.toStringAsFixed(1)} kg)',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  'S/ ${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: S/ ${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pedido creado el: ${_formatShortDate(order.createdAt)}',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
