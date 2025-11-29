import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Importa tus pantallas y modelos
import 'package:kuska_prototipos/Screens/saved_baskets_screen.dart';
import 'package:kuska_prototipos/product.dart';
import 'package:kuska_prototipos/Screens/product_detail_screen.dart';
import 'package:kuska_prototipos/cart.dart';
import 'package:kuska_prototipos/screens/cart_screen.dart';
import 'package:kuska_prototipos/screens/envios_screen.dart';
import 'package:kuska_prototipos/screens/profile_screen.dart';

class KuskaHomeScreen extends StatefulWidget {
  const KuskaHomeScreen({super.key});

  @override
  State<KuskaHomeScreen> createState() => _KuskaHomeScreenState();
}

class _KuskaHomeScreenState extends State<KuskaHomeScreen> {
  int _currentIndex = 0;
  
  // ESTADO 1: Filtro de categoría
  ProductCategory? _selectedCategory; 
  
  // ESTADO 2: Filtro de texto (Buscador)
  String _searchQuery = ''; 
  final TextEditingController _searchController = TextEditingController();

  final Color _kuskaGreen = const Color(0xFF002C28);
  final Color _bgGrey = const Color(0xFFF5F5F5);

  // LÓGICA DE FILTRADO COMBINADA (Categoría + Texto)
  List<Product> get _filteredProducts {
    // 1. Empezamos con todos los productos
    List<Product> list = mockProducts;

    // 2. Filtramos por categoría si hay una seleccionada
    if (_selectedCategory != null) {
      list = list.where((p) => p.categories.contains(_selectedCategory)).toList();
    }

    // 3. Filtramos por texto si el usuario escribió algo
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onProductTap(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
    setState(() {}); 
  }

  Widget _buildNavIcon(String assetPath, int index) {
    final isActive = _currentIndex == index;
    const activeColor = Color(0xFFFF8A3C);
    final inactiveColor = Colors.grey.shade400;

    return SvgPicture.asset(
      assetPath,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive ? activeColor : inactiveColor,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = _buildHomeContent();
        break;
      case 1:
        body = const EnviosScreen();
        break;
      case 2:
        body = const SavedBasketsScreen();
        break;
      case 3:
      default:
        body = const ProfileScreen();
        break;
    }

    return Scaffold(
      backgroundColor: _bgGrey,
      body: SafeArea(child: body),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ]
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedItemColor: const Color(0xFFFF8A3C),
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: _buildNavIcon('assets/icons/inicio.svg', 0)),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: _buildNavIcon('assets/icons/envios.svg', 1)),
              label: 'Envíos',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: _buildNavIcon('assets/icons/guardados.svg', 2)),
              label: 'Guardados',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: _buildNavIcon('assets/icons/perfil.svg', 3)),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Cart.instance.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
                setState(() {});
              },
              backgroundColor: _kuskaGreen,
              elevation: 4,
              icon: const Icon(Icons.shopping_basket_outlined, color: Colors.white),
              label: Text(
                'Ver canasta (${Cart.instance.items.length})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: _bgGrey,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kuska',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: _kuskaGreen,
                        ),
                      ),
                      Text(
                        'Hola, Maido Cocina Nikkei',
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.notifications_outlined, color: _kuskaGreen, size: 22),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // PASO EL CONTROLADOR Y LA FUNCIÓN DE CAMBIO AL WIDGET DEL BUSCADOR
              _SearchBarModern(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ],
          ),
        ),

        Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: 'Todo',
                isSelected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: 'Papas',
                isSelected: _selectedCategory == ProductCategory.papa,
                onTap: () => setState(() => _selectedCategory = ProductCategory.papa),
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: 'Aderezos',
                isSelected: _selectedCategory == ProductCategory.aderezo,
                onTap: () => setState(() => _selectedCategory = ProductCategory.aderezo),
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: 'Temporada',
                isSelected: _selectedCategory == ProductCategory.temporada,
                onTap: () => setState(() => _selectedCategory = ProductCategory.temporada),
              ),
            ],
          ),
        ),

        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        "No encontramos productos", 
                        style: GoogleFonts.inter(color: Colors.grey[600])
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // AJUSTE CLAVE: Relación de aspecto un poco más alta para que quepa todo
                    childAspectRatio: 0.70, 
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _ProductGridCard(
                      product: product,
                      onTap: () => _onProductTap(product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- WIDGETS ACTUALIZADOS ---

class _SearchBarModern extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _SearchBarModern({this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ]
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Buscar insumos (ej. Papa Huayro)',
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
          // Botón para borrar texto si hay contenido
          suffixIcon: controller?.text.isNotEmpty == true 
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () {
                  controller?.clear();
                  if(onChanged != null) onChanged!('');
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? const Color(0xFF002C28) : Colors.white;
    final textColor = isSelected ? Colors.white : Colors.grey[700];
    final borderColor = isSelected ? Colors.transparent : Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: isSelected 
            ? [BoxShadow(color: const Color(0xFF002C28).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
            : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductGridCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN ESTABILIZADA
            // Usamos AspectRatio 4:3 para obligar a un rectángulo perfecto
            AspectRatio(
              aspectRatio: 4 / 3, // Puedes cambiar a 1.0 para cuadrado
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover, // ESTO ES CLAVE: Recorta la imagen para llenar el hueco sin deformar
                      width: double.infinity,
                    ),
                  ),
                  // Badge S3
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco, size: 10, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 4),
                          Text(
                            product.s3Score.toStringAsFixed(1),
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // Info
            Expanded( // Usamos Expanded para que ocupe el resto del espacio disponible
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio verticalmente
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'S/ ${product.pricePerKg.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF002C28),
                              ),
                            ),
                            Text(
                              ' / kg',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Badge de pedido mínimo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pedido mín: ${product.minOrderKg.toStringAsFixed(0)}kg',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}