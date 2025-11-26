import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuska_prototipos/cart.dart';
import 'package:kuska_prototipos/Screens/order_detail_screen.dart';

class EnviosScreen extends StatelessWidget {
  const EnviosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Cart.instance;
    final orders = cart.orders;

    if (orders.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aún no tienes envíos.\nConfirma tu primera canasta y aparecerá aquí.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: orders.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Kuska',
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              );
            }

            final order = orders[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _OrderCard(order: order),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusInfo(order.status);
    final shortId = 'PED-${order.id.substring(order.id.length - 4)}';

    final totalKg = order.items.fold<double>(
      0,
      (sum, item) => sum + item.quantityKg,
    );

    final productsCount = order.items.length;

    final arrival = _formatArrival(order.deliveryStart, order.deliveryEnd);
    final created = _formatCreatedAt(order.createdAt);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 12,
              color: Color(0x22000000),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + badge
            Row(
              children: [
                Text(
                  shortId,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusStyle.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusStyle.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusStyle.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Llega...
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Llega: $arrival',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Kg + productos
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${totalKg.toStringAsFixed(1)} kg · $productsCount productos',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Total S/
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
            const SizedBox(height: 2),

            Text(
              'Pedido el: $created',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------
// Helpers de formato / estilo
// --------------------------------------------------------------

class _StatusStyle {
  final String label;
  final Color color;
  final Color background;

  _StatusStyle({
    required this.label,
    required this.color,
    required this.background,
  });
}

_StatusStyle _statusInfo(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return _StatusStyle(
        label: 'PENDIENTE',
        color: const Color(0xFF8A4A00),
        background: const Color(0xFFFFF3E0),
      );
    case OrderStatus.confirmed:
    case OrderStatus.inHub:
      return _StatusStyle(
        label: 'CONFIRMADO',
        color: const Color(0xFF005B4A),
        background: const Color(0xFFE0F2F1),
      );
    case OrderStatus.onRoute:
      return _StatusStyle(
        label: 'EN RUTA',
        color: const Color(0xFF4A148C),
        background: const Color(0xFFF3E5F5),
      );
    case OrderStatus.delivered:
      return _StatusStyle(
        label: 'ENTREGADO',
        color: const Color(0xFF1B5E20),
        background: const Color(0xFFE8F5E9),
      );
  }
}

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

  return '$w $day $m, $startH:$startM - $endH:$endM';
}

String _formatCreatedAt(DateTime dt) {
  final day = _twoDigits(dt.day);
  final month = _twoDigits(dt.month);
  final year = dt.year.toString().substring(2);
  final hour = _twoDigits(dt.hour);
  final minute = _twoDigits(dt.minute);
  return '$day/$month/$year · $hour:$minute';
}
