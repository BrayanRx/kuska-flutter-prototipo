import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuska_prototipos/cart.dart';

enum DeliverySlot {
  earlyBird,   // 05:00 - 07:00
  preService,  // 08:00 - 10:00
  afternoon,   // 14:00 - 16:00
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // 1 = mañana, 2 = pasado mañana
  int _selectedDateOffsetDays = 1;
  DeliverySlot _selectedSlot = DeliverySlot.preService;


  @override
  Widget build(BuildContext context) {
    final cart = Cart.instance;
    final items = cart.items;

    if (items.isEmpty) {
      // Por si alguien entra aquí sin canasta
      return Scaffold(
        appBar: AppBar(
          title: const Text('Confirmar y pagar'),
        ),
        body: const Center(
          child: Text('Tu canasta está vacía.'),
        ),
      );
    }

    final subtotal = cart.subtotal;
    final shippingCost = cart.shippingFee;
    final taxableBase = cart.taxableBase;
    final igv = cart.igv;
    final totalToPay = cart.finalTotal;


    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Confirmar y pagar',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DIRECCIÓN / VENTANA DE RECEPCIÓN
                  _DeliverySection(
                    selectedDateOffsetDays: _selectedDateOffsetDays,
                    onDateSelected: (offset) {
                      setState(() {
                        _selectedDateOffsetDays = offset;
                      });
                    },
                    selectedSlot: _selectedSlot,
                    onSlotSelected: (slot) {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // MÉTODO DE PAGO
                  _PaymentMethodSection(),
                  const SizedBox(height: 16),

                  // RESUMEN DE PEDIDO
                  Text(
                    'Resumen de pedido',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _OrderSummaryCard(items: items),
                  const SizedBox(height: 20),

                  // DESGLOSE DE COSTOS
                  Text(
                    'Desglose de costos',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                        _PriceRow(
                          label: 'Subtotal productos',
                          value: subtotal,
                        ),
                        _PriceRow(
                          label: 'Costo de envío',
                          value: shippingCost,
                        ),
                        const Divider(height: 20),
                        _PriceRow(
                          label: 'Base imponible (afecta IGV)',
                          value: taxableBase,
                        ),
                        _PriceRow(
                          label: 'IGV 18%',
                          value: igv,
                        ),
                        const SizedBox(height: 8),
                        _PriceRow(
                          label: 'Total a pagar',
                          value: totalToPay,
                          isBold: true,
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FACTURA / SUNAT
                  Text(
                    'Datos de factura (SUNAT – mock)',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _InvoiceCard(),
                  const SizedBox(height: 80), // margen extra bajo el botón fijo
                ],
              ),
            ),
          ),

          // FOOTER: TOTAL + BOTÓN DE PAGO
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -2),
                  blurRadius: 10,
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total a pagar',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'S/ ${totalToPay.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final order = cart.confirmOrder();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pago exitoso. Pedido generado: ${order.id}',
                              ),
                            ),
                          );

                          Navigator.of(context).pop(); // cerrar checkout
                          Navigator.of(context).pop(); // cerrar canasta
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002C28),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Pagar ahora',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- SECCIÓN DE ENTREGA (dirección + ventana de recepción) ----------

class _DeliverySection extends StatelessWidget {
  final int selectedDateOffsetDays;
  final ValueChanged<int> onDateSelected;
  final DeliverySlot selectedSlot;
  final ValueChanged<DeliverySlot> onSlotSelected;

  const _DeliverySection({
    required this.selectedDateOffsetDays,
    required this.onDateSelected,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  String _weekdayShort(DateTime d) {
    const names = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
    return names[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    String slotTitle(DeliverySlot slot) {
      switch (slot) {
        case DeliverySlot.earlyBird:
          return 'Early Bird';
        case DeliverySlot.preService:
          return 'Pre-Service';
        case DeliverySlot.afternoon:
          return 'Afternoon';
      }
    }

    String slotRange(DeliverySlot slot) {
      switch (slot) {
        case DeliverySlot.earlyBird:
          return '05:00 – 07:00';
        case DeliverySlot.preService:
          return '08:00 – 10:00';
        case DeliverySlot.afternoon:
          return '14:00 – 16:00';
      }
    }

    final selectedDate = selectedDateOffsetDays == 1 ? tomorrow : dayAfterTomorrow;

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
          // Dirección principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Depósito del restaurante',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ca. San Martín No. 399, Miraflores 15074',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Referencia: Restaurante Maido',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // futuro: selector de dirección
                },
                child: const Text('Cambiar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 16),
          const SizedBox(height: 4),

          // Fecha de recepción
          Text(
            'Ventana de recepción',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _DateChip(
                title: 'Para mañana',
                subtitle: '${_weekdayShort(tomorrow)} ${tomorrow.day}/${tomorrow.month}',
                selected: selectedDateOffsetDays == 1,
                onTap: () => onDateSelected(1),
              ),
              const SizedBox(width: 8),
              _DateChip(
                title: 'Para pasado mañana',
                subtitle:
                    '${_weekdayShort(dayAfterTomorrow)} ${dayAfterTomorrow.day}/${dayAfterTomorrow.month}',
                selected: selectedDateOffsetDays == 2,
                onTap: () => onDateSelected(2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Bloque horario',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _SlotChip(
                title: 'Early Bird (05:00 – 07:00)',
                subtitle: 'Ideal para panaderías o servicio de desayuno.',
                selected: selectedSlot == DeliverySlot.earlyBird,
                onTap: () => onSlotSelected(DeliverySlot.earlyBird),
              ),
              const SizedBox(height: 8),
              _SlotChip(
                title: 'Pre-Service (08:00 – 10:00)',
                subtitle: 'Ventana estándar para prep de almuerzos.',
                selected: selectedSlot == DeliverySlot.preService,
                onTap: () => onSlotSelected(DeliverySlot.preService),
              ),
              const SizedBox(height: 8),
              _SlotChip(
                title: 'Afternoon (14:00 – 16:00)',
                subtitle: 'Reposición para turno de noche/cena.',
                selected: selectedSlot == DeliverySlot.afternoon,
                onTap: () => onSlotSelected(DeliverySlot.afternoon),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Resumen chiquito
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Entrega estimada: '
                    '${_weekdayShort(selectedDate)} ${selectedDate.day}/${selectedDate.month}, '
                    '${slotTitle(selectedSlot)} (${slotRange(selectedSlot)})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF00A67A) : const Color(0xFFE0E0E0);
    final bgColor = selected ? const Color(0xFFE5F6F1) : Colors.white;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF00A67A) : const Color(0xFFE0E0E0);
    final bgColor = selected ? const Color(0xFFE5F6F1) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color:
                  selected ? const Color(0xFF00A67A) : Colors.black38,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- SECCIÓN MÉTODO DE PAGO ----------

class _PaymentMethodSection extends StatelessWidget {
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
          Row(
            children: [
              Text(
                'Método de pago',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // aquí iría la selección de tarjeta/cuenta en el futuro
                },
                child: const Text('Cambiar'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 38,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F71),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Débito •••• 8458',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'MITSUHARU TSUMURA',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------- CARD RESUMEN DE PRODUCTOS ----------

class _OrderSummaryCard extends StatelessWidget {
  final List<CartItem> items;

  const _OrderSummaryCard({required this.items});

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
          for (final item in items) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name} (${item.quantityKg.toStringAsFixed(1)} kg)',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'S/ ${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// ---------- ROW DE PRECIO ----------

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
      padding: const EdgeInsets.symmetric(vertical: 4),
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

/// ---------- CARD DE FACTURA / SUNAT (mock) ----------

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InvoiceRow(label: 'Tipo de comprobante', value: 'Factura electrónica'),
          _InvoiceRow(label: 'RUC restaurante', value: '2060XXXXXXX'),
          _InvoiceRow(label: 'Razón social', value: 'Restaurante Demo S.A.C.'),
          _InvoiceRow(label: 'Dirección fiscal', value: 'Av. Ejemplo 123, Lima'),
          _InvoiceRow(label: 'Moneda', value: 'PEN'),
          SizedBox(height: 6),
          Text(
            'Cuando se integre la API de SUNAT, aquí se verán:\n'
            '• Serie y número de factura\n'
            '• Hash de seguridad\n'
            '• Enlace a PDF / representación impresa\n'
            '• Estado de aceptación en SUNAT',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;

  const _InvoiceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
