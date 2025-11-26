import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kuska_prototipos/product.dart';
import 'package:kuska_prototipos/Screens/product_detail_screen.dart';
import 'package:kuska_prototipos/cart.dart';
import 'package:kuska_prototipos/screens/cart_screen.dart';
import 'package:kuska_prototipos/screens/envios_screen.dart';

class KuskaHomeScreen extends StatefulWidget {
  const KuskaHomeScreen({super.key});

  @override
  State<KuskaHomeScreen> createState() => _KuskaHomeScreenState();
}

class _KuskaHomeScreenState extends State<KuskaHomeScreen> {
  int _currentIndex = 0;

  // Filtra productos por categoría
  List<Product> _productsFor(ProductCategory category) {
    return mockProducts
        .where((p) => p.categories.contains(category))
        .toList();
  }

  Future<void> _onProductTap(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
    // Al volver, refrescamos el FAB "Ver canasta"
    setState(() {});
  }

  Widget _buildNavIcon(String assetPath, int index) {
    final isActive = _currentIndex == index;
    const activeColor = Color(0xFFFF8A3C); // naranja
    final inactiveColor = Colors.grey.shade400;

    return SvgPicture.asset(
      assetPath,
      height: 26,
      colorFilter: ColorFilter.mode(
        isActive ? activeColor : inactiveColor,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Elegimos qué pantalla mostrar según el tab
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Text(
              'Kuska',
              style: GoogleFonts.libreBaskerville(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            const _SearchBar(),
            const SizedBox(height: 28),
            _SectionWithList(
              title: 'Variedades de papa',
              onSeeAll: () {},
              products: _productsFor(ProductCategory.papa),
              onProductTap: _onProductTap,
            ),
            const SizedBox(height: 24),
            _SectionWithList(
              title: 'Para el aderezo',
              onSeeAll: () {},
              products: _productsFor(ProductCategory.aderezo),
              onProductTap: _onProductTap,
            ),
            const SizedBox(height: 24),
            _SectionWithList(
              title: 'En temporada',
              onSeeAll: () {},
              products: _productsFor(ProductCategory.temporada),
              onProductTap: _onProductTap,
            ),
            const SizedBox(height: 80), // espacio para el FAB
          ],
        );
        break;
      case 1:
        body = const EnviosScreen();
        break;
      case 2:
        body = const Center(child: Text('Guardados (pendiente)'));
        break;
      case 3:
      default:
        body = const Center(child: Text('Perfil (pendiente)'));
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: body),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xFFFF8A3C),
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/inicio.svg', 0),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/envios.svg', 1),
            label: 'Envíos',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/guardados.svg', 2),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/perfil.svg', 3),
            label: 'Perfil',
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Cart.instance.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
                setState(() {}); // actualizar visibilidad al volver
              },
              backgroundColor: const Color(0xFF002C28),
              icon: const Icon(
                Icons.shopping_basket_outlined,
                color: Colors.white,
              ),
              label: Text(
                'Ver canasta (${Cart.instance.items.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar productos',
        prefixIcon: const Icon(Icons.search, size: 24),
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionWithList extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final List<Product> products;
  final void Function(Product) onProductTap;

  const _SectionWithList({
    required this.title,
    required this.onSeeAll,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Mostrar todo >',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                onTap: () => onProductTap(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                showS3Modal(context, product);
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'S³',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.s3Score.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'S/ ${product.pricePerKg.toStringAsFixed(2)} x kg',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Modal S³ (igual que ya tenías) ----

void showS3Modal(BuildContext context, Product product) {
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

class _S3DetailsSheet extends StatelessWidget {
  final Product product;

  const _S3DetailsSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFF004D40),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'S³',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${product.s3Score.toStringAsFixed(1)} / 5',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Este score resume el desempeño del productor en tres dimensiones: ambiental, social y económica.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),
                _S3DimensionCard(
                  title: 'Ambiental',
                  emoji: '🌿',
                  titleColor: const Color(0xFF2E7D32),
                  description:
                      'Impacto ambiental y eficiencia operativa',
                  metrics: [
                    '${product.mermasEvitadas}% - Mermas evitadas',
                    '${product.co2KgPorKg} kg - CO₂ por kg transportado',
                  ],
                ),
                const SizedBox(height: 16),
                _S3DimensionCard(
                  title: 'Social',
                  emoji: '👥',
                  titleColor: const Color(0xFFB23A48),
                  description:
                      'Beneficios al productor y prácticas responsables',
                  metrics: [
                    '${product.pagoDirecto}% - % de pago directo',
                    '${product.tiempoPromedioPago} h - Tiempo promedio de pago',
                    '<${product.tiempoEntrega} - Tiempo de entrega',
                  ],
                ),
                const SizedBox(height: 16),
                _S3DimensionCard(
                  title: 'Económico',
                  emoji: '💰',
                  titleColor: const Color(0xFF8C3100),
                  description:
                      'Estabilidad y transparencia del comercio',
                  metrics: [
                    '${product.puntualidad}% - puntualidad en entregas',
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _S3DimensionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color titleColor;
  final String description;
  final List<String> metrics;

  const _S3DimensionCard({
    required this.title,
    required this.emoji,
    required this.titleColor,
    required this.description,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$emoji ',
                  style: const TextStyle(fontSize: 16),
                ),
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    fontSize: 15,
                  ),
                ),
              ],
              style: const TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          for (final m in metrics) ...[
            Text(
              m,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
