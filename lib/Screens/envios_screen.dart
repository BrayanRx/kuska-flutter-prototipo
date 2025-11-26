import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kuska_prototipos/cart.dart';

class EnviosScreen extends StatelessWidget {
  const EnviosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Cart.instance.orders;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kuska',
                style: GoogleFonts.libreBaskerville(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mis envíos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              if (orders.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Aún no tienes envíos.\nConfirma tu primer pedido desde Inicio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCard(order: order);
                    },
                  ),
                ),
            ],
          ),
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
    final totalKg = order.items.fold<double>(
      0,
      (sum, item) => sum + item.quantityKg,
    );

    final created = order.createdAt;
    final dateStr =
        '${_two(created.day)}/${_two(created.month)}/${created.year.toString().substring(2)}';
    final hourStr =
        '${_two(created.hour)}:${_two(created.minute)}';

    final isPending = order.status == OrderStatus.confirmed;
    final statusText = isPending ? 'pendiente' : 'recibido';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila: ID + estado + Ver detalle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _formatOrderId(order.id),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    text: isPending ? 'PENDIENTE' : 'RECIBIDO',
                    isPending: isPending,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver detalle',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 18,
                color: Color(0xFF263238),
              ),
              const SizedBox(width: 6),
              Text(
                '$dateStr · $hourStr ($statusText)',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: Color(0xFF263238),
              ),
              const SizedBox(width: 6),
              Text(
                '${totalKg.toStringAsFixed(0)} kg',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: Color(0xFF263238),
              ),
              const SizedBox(width: 6),
              Text(
                'S/. ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool isPending;

  const _StatusChip({
    required this.text,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPending
        ? const Color(0xFFFFF3CD) // amarillo suave
        : const Color(0xFFE3F6E6); // verde suave

    final textColor = isPending
        ? const Color(0xFFB25B00) // naranja oscuro
        : const Color(0xFF1B5E20); // verde oscuro

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final totalKg = order.items.fold<double>(
      0,
      (sum, item) => sum + item.quantityKg,
    );

    final created = order.createdAt;
    final dateStr =
        '${_two(created.day)}/${_two(created.month)}/${created.year.toString().substring(2)}';
    final hourStr =
        '${_two(created.hour)}:${_two(created.minute)}';

    final isPending = order.status == OrderStatus.confirmed;
    final statusText = isPending ? 'Pendiente' : 'Recibido';

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatOrderId(order.id)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado + fecha/hora
            Row(
              children: [
                _StatusChip(
                  text: isPending ? 'PENDIENTE' : 'RECIBIDO',
                  isPending: isPending,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$dateStr · $hourStr',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Resumen numérico
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del envío',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${totalKg.toStringAsFixed(1)} kg en total',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'S/. ${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Estado: $statusText',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Productos del pedido',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  final product = item.product;
                  final subtotal = item.total;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            product.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.quantityKg.toStringAsFixed(1)} kg · S/ ${product.pricePerKg.toStringAsFixed(2)} x kg',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'S/ ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

// Utils compartidos

String _formatOrderId(String rawId) {
  final suffix = rawId.length <= 4
      ? rawId
      : rawId.substring(rawId.length - 4);
  return 'PED-$suffix';
}

String _two(int v) => v.toString().padLeft(2, '0');
