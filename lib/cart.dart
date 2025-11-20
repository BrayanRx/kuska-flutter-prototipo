// lib/cart.dart
import 'package:kuska_prototipos/product.dart';

class CartItem {
  final Product product;
  double quantityKg;

  CartItem({
    required this.product,
    required this.quantityKg,
  });

  double get total => product.pricePerKg * quantityKg;
}

enum OrderStatus {
  confirmed,
  delivered, // por si luego quieres usarlo
}

class Order {
  final String id;
  final DateTime createdAt;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;

  Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.status,
  });
}

/// Carrito en memoria (singleton simple para demo)
class Cart {
  Cart._internal();
  static final Cart instance = Cart._internal();

  final List<CartItem> _items = [];
  final List<Order> _orders = [];

  List<CartItem> get items => List.unmodifiable(_items);
  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _items.isEmpty;

  double get total =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  /// Añadir producto a la canasta.
  /// Si ya existe, suma la cantidad.
  void addProduct(Product product, double quantityKg) {
    if (quantityKg <= 0) return;

    final index = _items.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (index >= 0) {
      _items[index].quantityKg += quantityKg;
    } else {
      _items.add(CartItem(
        product: product,
        quantityKg: quantityKg,
      ));
    }
  }

  /// Eliminar un producto de la canasta
  void removeProduct(Product product) {
    _items.removeWhere((item) => item.product.name == product.name);
  }

  /// Vaciar carrito sin tocar historial
  void clear() {
    _items.clear();
  }

  /// Crear un pedido a partir del carrito actual
  Order confirmOrder() {
    if (_items.isEmpty) {
      throw StateError('No hay productos en la canasta');
    }

    final orderItems = _items
        .map((item) => CartItem(
              product: item.product,
              quantityKg: item.quantityKg,
            ))
        .toList();

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      items: orderItems,
      total: total,
      status: OrderStatus.confirmed,
    );

    _orders.insert(0, order); // primero el más reciente
    _items.clear();

    return order;
  }
}
