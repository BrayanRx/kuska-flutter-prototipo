// lib/saved_baskets.dart
import 'package:kuska_prototipos/cart.dart';

/// Canasta guardada para reutilizar más adelante.
class SavedBasket {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<CartItem> items;

  SavedBasket({
    required this.id,
    required this.name,
    required this.createdAt,
    required List<CartItem> items,
  }) : items = List.unmodifiable(items);

  /// Subtotal estimado usando los precios actuales del producto.
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.total);

  /// Resumen tipo: "Papa amarilla, Cebolla roja y 3 más"
  String get shortSummary {
    if (items.isEmpty) return '';

    final names = items.map((e) => e.product.name).toList();

    if (names.length == 1) {
      return names.first;
    } else if (names.length == 2) {
      return '${names[0]}, ${names[1]}';
    } else {
      final remaining = names.length - 2;
      return '${names[0]}, ${names[1]} y $remaining más';
    }
  }
}

/// Manager en memoria para manejar las canastas guardadas (singleton).
class SavedBasketsManager {
  SavedBasketsManager._internal();
  static final SavedBasketsManager instance =
      SavedBasketsManager._internal();

  final List<SavedBasket> _baskets = [];

  /// Lista inmodificable hacia afuera.
  List<SavedBasket> get baskets => List.unmodifiable(_baskets);

  /// Guardar una canasta a partir de una lista de CartItem.
  /// IMPORTANTE: hace copia profunda de los CartItem.
  SavedBasket saveBasket({
    required String name,
    required List<CartItem> items,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('El nombre de la canasta no puede estar vacío.');
    }
    if (items.isEmpty) {
      throw StateError('No hay productos para guardar en la canasta.');
    }

    // Deep copy: nuevos CartItem, no referencias a los del carrito.
    final clonedItems = items
        .map((item) => CartItem(
              product: item.product,      // Product es inmutable; ok reutilizarlo
              quantityKg: item.quantityKg,
            ))
        .toList();

    final basket = SavedBasket(
      id: _generateId(),
      name: trimmedName,
      createdAt: DateTime.now(),
      items: clonedItems,
    );

    // Insertamos al inicio para que lo más reciente aparezca primero.
    _baskets.insert(0, basket);
    return basket;
  }

  /// Eliminar una canasta por id.
  void deleteBasket(String id) {
    _baskets.removeWhere((b) => b.id == id);
  }

  /// Limpia todo (por si quieres resetear en debug/demo).
  void clear() {
    _baskets.clear();
  }

  String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
