enum ProductCategory {
    papa,
    aderezo,
    temporada,
    oferta,
    destacado,
  }

class Product {
  final String name;
  final String imageUrl;
  final double pricePerKg;
  final double rating;

  // Métricas del score Ambiental
  final double mermasEvitadas;      // en %
  final double co2KgPorKg;          // en kg CO2 por kg transportado

  // Métricas del score Social
  final double pagoDirecto;         // en %
  final double tiempoPromedioPago;  // en horas
  final double tiempoEntrega;       // en horas

  // Métricas del score Económico
  final double puntualidad;         // en %

  final List<ProductCategory> categories;

  /// Mínimo de kg por pedido para este producto
  final double minOrderKg;

  // Constructor
  const Product({
    required this.name,
    required this.imageUrl,
    required this.pricePerKg,
    required this.rating,
    required this.mermasEvitadas,
    required this.co2KgPorKg,
    required this.pagoDirecto,
    required this.tiempoPromedioPago,
    required this.tiempoEntrega,
    required this.puntualidad,
    required this.categories,
    required this.minOrderKg,
  });

  /// 0–5 ENV score
  double get envScore {
    final mermas = normalize(mermasEvitadas, best: 30, worst: 0);
    final co2 = normalize(co2KgPorKg, best: 0.3, worst: 2.0, inverse: true);
    return (mermas + co2) / 2;
  }

  /// 0–5 SOCIAL score
  double get socialScore {
    final pago = normalize(pagoDirecto, best: 90, worst: 30);
    final pagoTiempo = normalize(tiempoPromedioPago, best: 24, worst: 120, inverse: true);
    final entrega = normalize(tiempoEntrega, best: 24, worst: 48, inverse: true);
    return (3*pago + pagoTiempo + 2*entrega) / 6;
  }

  /// 0–5 ECONÓMICO score
  double get economicScore {
    return normalize(puntualidad, best: 100, worst: 60);
  }

  /// Score global
  double get s3Score {
    const wEnv = 0.4;
    const wSoc = 0.3;
    const wEco = 0.3;
    return envScore * wEnv + socialScore * wSoc + economicScore * wEco;
  }
}

/// Normalizador genérico: convierte métrica al rango 1–5
double normalize(double raw, {
  required double best,
  required double worst,
  bool inverse = false,
}) {
  final minVal = best < worst ? best : worst;
  final maxVal = best < worst ? worst : best;

  final v = raw.clamp(minVal, maxVal);
  double t = (v - worst) / (best - worst);
  if (inverse) t = 1 - t;

  return 3 + 2 * t;
}

const mockProducts = <Product>[
  Product(
    name: 'Papa amarilla',
    imageUrl: 'assets/products/papa-amarilla.png',
    pricePerKg: 1.80,
    rating: 4.6,
    mermasEvitadas: 22,
    co2KgPorKg: 0.7,
    pagoDirecto: 78,
    tiempoPromedioPago: 36,
    tiempoEntrega: 20,
    puntualidad: 94,
    categories: [
      ProductCategory.papa,
      ProductCategory.destacado,],
      minOrderKg: 20,
  ),
  Product(
    name: 'Papa Huayro',
    imageUrl: 'assets/products/papa-huayro-r.png',
    pricePerKg: 1.30,
    rating: 4.7,
    mermasEvitadas: 18,
    co2KgPorKg: 0.8,
    pagoDirecto: 72,
    tiempoPromedioPago: 48,
    tiempoEntrega: 24,
    puntualidad: 96,
    categories: [
      ProductCategory.papa,
    ],
    minOrderKg: 15,
  ),

  Product(
    name: 'Mango',
    imageUrl: 'assets/products/mango.png',
    pricePerKg: 2.00,
    rating: 4.8,
    mermasEvitadas: 18,
    co2KgPorKg: 1.0,
    pagoDirecto: 70,
    tiempoPromedioPago: 24,
    tiempoEntrega: 24,
    puntualidad: 95,
    categories: [
      ProductCategory.temporada,
    ],
    minOrderKg: 10,
  ),

  Product(
    name: 'Ajo entero',
    imageUrl: 'assets/products/ajo-entero.png',
    pricePerKg: 10.00,
    rating: 4.8,
    mermasEvitadas: 18,
    co2KgPorKg: 0.9,
    pagoDirecto: 75,
    tiempoPromedioPago: 24,
    tiempoEntrega: 48,
    puntualidad: 98,
    categories: [
      ProductCategory.aderezo,
    ],
    minOrderKg: 5,
  ),

  // 🔥 Ají amarillo
  Product(
    name: 'Ají amarillo',
    imageUrl: 'assets/products/aji-amarillo.png',
    pricePerKg: 1.00,
    rating: 4.5,
    mermasEvitadas: 20,    // buen manejo postcosecha
    co2KgPorKg: 0.9,       // algo más alto que la papa pero aceptable
    pagoDirecto: 75,
    tiempoPromedioPago: 48,
    tiempoEntrega: 22,
    puntualidad: 92,
    categories: [
      ProductCategory.aderezo,
      ProductCategory.temporada,
    ],
    minOrderKg: 8,
  ),

  // 🧅 Cebolla roja
  Product(
    name: 'Cebolla roja',
    imageUrl: 'assets/products/cebolla-roja.png',
    pricePerKg: 1.50,
    rating: 4.2,
    mermasEvitadas: 18,
    co2KgPorKg: 1.0,
    pagoDirecto: 70,
    tiempoPromedioPago: 60,
    tiempoEntrega: 24,
    puntualidad: 90,
    categories: [
      ProductCategory.aderezo,
    ],
    minOrderKg: 12,
  ),

  
];