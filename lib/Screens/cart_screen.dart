import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuska_prototipos/cart.dart';
import 'package:kuska_prototipos/screens/checkout_screen.dart';
import 'package:kuska_prototipos/saved_baskets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Color corporativo
  final Color _kuskaGreen = const Color(0xFF002C28);

  @override
  Widget build(BuildContext context) {
    final cart = Cart.instance;

    // --- ESTADO VACÍO ---
    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
                  child: Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu canasta está vacía',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega insumos frescos para comenzar tu pedido.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kuskaGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 2,
                    ),
                    child: Text('Ir al Catálogo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- ESTADO CON PRODUCTOS ---
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Lista de items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItemCard(
                  item: item,
                  onRemove: () {
                    setState(() {
                      Cart.instance.removeProduct(item.product);
                    });
                    if (Cart.instance.isEmpty) setState(() {});
                  },
                );
              },
            ),
          ),

          // Footer Fijo
          _buildFooter(context, cart),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: true,
      title: Text(
        'Mi Canasta',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen de costos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total estimado', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
                Text(
                  'S/ ${cart.total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: _kuskaGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Botón Principal: Pagar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kuskaGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: _kuskaGreen.withOpacity(0.4),
                ),
                child: Text('Proceder al Pago', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón Secundario: Guardar (CON OPTIMIZACIÓN DE LAG)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: () async {
                  // 1. Cerrar teclado explícitamente
                  FocusScope.of(context).unfocus();
                  
                  // 2. Esperar a que la animación del teclado termine (CLAVE PARA EL LAG)
                  await Future.delayed(const Duration(milliseconds: 250));

                  // 3. Mostrar diálogo solo si el widget sigue montado
                  if (context.mounted) {
                    _showSaveBasketDialog(context);
                  }
                },
                icon: const Icon(Icons.bookmark_border, size: 20),
                label: Text('Guardar para después', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGO REDISEÑADO (Blanco y Limpio) ---
  void _showSaveBasketDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white, // Fondo blanco puro
          surfaceTintColor: Colors.white, // Quita el tinte rosa/morado de Material 3
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          
          title: Text(
            'Guardar plantilla', 
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)
          ),
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asigna un nombre para identificar este pedido.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              
              // TextField estilizado con colores de marca
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                textCapitalization: TextCapitalization.sentences,
                cursorColor: _kuskaGreen,
                decoration: InputDecoration(
                  labelText: 'Nombre de la canasta',
                  hintText: 'Ej. Lunes de Verduras',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  
                  // Bordes personalizados
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _kuskaGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          actions: [
            // Botón Cancelar (Gris)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            
            // Botón Guardar (Verde Corporativo)
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                try {
                  SavedBasketsManager.instance.saveBasket(
                    name: name,
                    items: Cart.instance.items,
                  );
                  Navigator.of(dialogContext).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Plantilla "$name" guardada'),
                      backgroundColor: _kuskaGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                } catch (e) {
                  // Manejo de errores
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kuskaGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Guardar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}

// --- WIDGET DE TARJETA DE PRODUCTO ---
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;

  const _CartItemCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.product.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            
            // Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${item.quantityKg} kg',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'x S/ ${item.product.pricePerKg.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total y Eliminar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${item.total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(Icons.delete_outline, size: 20, color: Colors.red[300]),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}