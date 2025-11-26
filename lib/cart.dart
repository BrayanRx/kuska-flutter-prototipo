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

/// Estados logísticos del pedido
enum OrderStatus {
  pending,   // recién creado
  confirmed, // confirmado / en preparación
  inHub,     // en centro de acopio
  onRoute,   // en ruta hacia Lima
  delivered, // entregado
}

class Order {
  final String id;
  final DateTime createdAt;

  /// Ventana de entrega comprometida
  final DateTime deliveryStart;
  final DateTime deliveryEnd;
  final String deliveryWindowLabel;
  final String deliveryAddress;

  final List<CartItem> items;

  /// Desglose financiero
  final double subtotal;     // solo productos
  final double shippingFee;  // fee logístico
  final double taxableBase;  // base imponible
  final double igv;          // IGV 18%
  final double total;        // total a pagar

  final OrderStatus status;

  Order({
    required this.id,
    required this.createdAt,
    required this.deliveryStart,
    required this.deliveryEnd,
    required this.deliveryWindowLabel,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.taxableBase,
    required this.igv,
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


  /// Subtotal de productos (sin envío ni IGV)
  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  /// Alias para no romper pantallas que usan `cart.total`
  double get total => subtotal;


  /// 10% del valor del producto, redondeado hacia arriba
  double get shippingFee {
    final fee = subtotal * 0.10;
    return fee.ceilToDouble();
  }

  double get taxableBase => subtotal + shippingFee;

  double get igv => taxableBase * 0.18;

  double get finalTotal => taxableBase + igv;

  // ---------------------------------------------------------------------------
  // Operaciones sobre la canasta
  // ---------------------------------------------------------------------------

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

  /// Crear un pedido a partir del carrito actual.
  ///
  /// Para el prototipo, si no pasas nada de entrega usa:
  /// - Mañana, ventana Pre-Service (08:00 - 10:00)
  /// - Dirección mock del restaurante.
  Order confirmOrder({
    DateTime? deliveryStart,
    DateTime? deliveryEnd,
    String? deliveryWindowLabel,
    String deliveryAddress =
        'Depósito del restaurante, Ca. San Martín 399, Miraflores',
    OrderStatus status = OrderStatus.confirmed,
  }) {
    if (_items.isEmpty) {
      throw StateError('No hay productos en la canasta');
    }

    final now = DateTime.now();

    // Ventana por defecto: mañana Pre-Service 08:00–10:00
    final tomorrow = now.add(const Duration(days: 1));
    final baseDate =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final start = deliveryStart ?? baseDate.add(const Duration(hours: 8));
    final end = deliveryEnd ?? baseDate.add(const Duration(hours: 10));
    final slotLabel =
        deliveryWindowLabel ?? 'Pre-Service (08:00 - 10:00)';

    final orderItems = _items
        .map((item) => CartItem(
              product: item.product,
              quantityKg: item.quantityKg,
            ))
        .toList();

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: now,
      deliveryStart: start,
      deliveryEnd: end,
      deliveryWindowLabel: slotLabel,
      deliveryAddress: deliveryAddress,
      items: orderItems,
      subtotal: subtotal,
      shippingFee: shippingFee,
      taxableBase: taxableBase,
      igv: igv,
      total: finalTotal,
      status: status,
    );

    _orders.insert(0, order); // primero el más reciente
    _items.clear();

    return order;
  }
}
