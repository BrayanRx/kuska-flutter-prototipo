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
  
  // Color corporativo
  final Color _kuskaGreen = const Color(0xFF002C28);

  @override
  Widget build(BuildContext context) {
    final baskets = manager.baskets;

    // --- ESTADO VACÍO ---
    if (baskets.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Icon(Icons.bookmark_border, size: 48, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                Text(
                  'No tienes plantillas guardadas',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Arma tu canasta y guárdala para repetir tus pedidos frecuentes con un solo clic.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- LISTA DE GUARDADOS ---
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // No usamos AppBar aquí porque el título ya viene del Home (BottomNav)
      // Si esta pantalla se abre sola, podrías descomentar el AppBar
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: baskets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final basket = baskets[index];
          return _SavedBasketCard(
            basket: basket,
            kuskaGreen: _kuskaGreen,
            onDelete: () {
              // Confirmación antes de borrar
              _showDeleteConfirmDialog(context, basket);
            },
            onReorder: () => _handleReorder(context, basket),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SavedBasket basket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar plantilla?'),
        content: Text('Se borrará la lista "${basket.name}". Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                manager.deleteBasket(basket.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plantilla eliminada')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReorder(BuildContext context, SavedBasket basket) async {
    // Diálogo estilo iOS/Material moderno
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cargar "${basket.name}"',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Se agregarán ${basket.items.length} productos a tu canasta actual con los precios vigentes de hoy.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuskaGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Agregar al Carrito'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirm != true) return;

    final cart = Cart.instance;
    for (final item in basket.items) {
      cart.addProduct(item.product, item.quantityKg);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Productos agregados al carrito'),
        backgroundColor: _kuskaGreen,
        action: SnackBarAction(
          label: 'VER CANASTA',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
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
  final Color kuskaGreen;

  const _SavedBasketCard({
    required this.basket,
    required this.onDelete,
    required this.onReorder,
    required this.kuskaGreen,
  });

  @override
  Widget build(BuildContext context) {
    // Formateo de fecha
    final date = basket.createdAt;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    // Preview de imágenes (máximo 4)
    final previewImages = basket.items.take(4).map((e) => e.product.imageUrl).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Header de la tarjeta
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        basket.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Creado el $dateStr · ${basket.items.length} items',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  tooltip: 'Opciones',
                ),
              ],
            ),
          ),

          const Divider(height: 24, thickness: 0.5),

          // Preview de productos (Miniaturas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: previewImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(previewImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Footer con Precio y Botón
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total estimado',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                    ),
                    Text(
                      '~ S/ ${basket.totalEstimated.toStringAsFixed(2)}', // Asegúrate de tener este getter en saved_baskets.dart
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onReorder,
                  icon: const Icon(Icons.replay, size: 18),
                  label: Text('Pedir de nuevo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kuskaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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