// lib/screens/saved_baskets_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuska_prototipos/cart.dart';
import 'package:kuska_prototipos/saved_baskets.dart';
import 'package:kuska_prototipos/screens/cart_screen.dart';

class SavedBasketsScreen extends StatefulWidget {
  const SavedBasketsScreen({super.key});

  @override
  State<SavedBasketsScreen> createState() => _SavedBasketsScreenState();
}

class _SavedBasketsScreenState extends State<SavedBasketsScreen> {
  final manager = SavedBasketsManager.instance;

  @override
  Widget build(BuildContext context) {
    final baskets = manager.baskets;

    // ESTADO VACÍO
    if (baskets.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text(
            'Mis guardados',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aún no tienes canastas guardadas',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Guarda una canasta desde la pantalla de “Canasta” para reutilizarla rápidamente en tus próximos pedidos.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      );
    }

    // LISTA NORMAL
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Mis guardados',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: baskets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final basket = baskets[index];
          return _SavedBasketCard(
            basket: basket,
            onDelete: () {
              // SOLO borrar + setState, NADA de Navigator aquí
              setState(() {
                manager.deleteBasket(basket.id);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Canasta "${basket.name}" eliminada.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onReorder: () => _handleReorder(context, basket),
          );
        },
      ),
    );
  }

  Future<void> _handleReorder(
      BuildContext context, SavedBasket basket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pedir de nuevo'),
          content: Text(
            '¿Agregar los productos de "${basket.name}" a tu canasta actual?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Lógica aditiva: sumar al carrito actual
    final cart = Cart.instance;
    for (final item in basket.items) {
      cart.addProduct(item.product, item.quantityKg);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se agregaron los productos de "${basket.name}" a tu canasta.',
        ),
        action: SnackBarAction(
          label: 'Ir a la canasta',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedBasketCard extends StatelessWidget {
  final SavedBasket basket;
  final VoidCallback onDelete;
  final VoidCallback onReorder;

  const _SavedBasketCard({
    required this.basket,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final created =
        '${basket.createdAt.day.toString().padLeft(2, '0')}/'
        '${basket.createdAt.month.toString().padLeft(2, '0')}/'
        '${basket.createdAt.year}';

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
          // Título + acciones
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  basket.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                tooltip: 'Eliminar canasta',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            basket.shortSummary,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Creada el $created',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total estimado',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              Text(
                'S/ ${basket.subtotal.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onReorder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002C28),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Pedir de nuevo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
