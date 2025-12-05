enum ProductCategory {
  papa,
  aderezo,
  temporada,
  oferta,
  destacado,
}

// NUEVO: Definimos los tipos de tendencia posibles
enum PriceTrend {
  rising,   // Sube (Escasez)
  falling,  // Baja (Cosecha masiva)
  stable,   // Estable (Normal)
}

class Product {
  final String name;
  final String imageUrl;
  final double pricePerKg;
  final double rating;

  // Métricas del score Ambiental
  final double mermasEvitadas;
  final double co2KgPorKg;

  // Métricas del score Social
  final double pagoDirecto;
  final double tiempoPromedioPago;
  final double tiempoEntrega;

  // Métricas del score Económico
  final double puntualidad;

  final List<ProductCategory> categories;
  final double minOrderKg;
  
  // NUEVO: La tendencia del producto
  final PriceTrend trend;

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
    this.trend = PriceTrend.stable, // Valor por defecto
  });

  // Getters para scores (igual que antes)
  double get envScore {
    final mermas = normalize(mermasEvitadas, best: 30, worst: 0);
    final co2 = normalize(co2KgPorKg, best: 0.3, worst: 2.0, inverse: true);
    return (mermas + co2) / 2;
  }

  double get socialScore {
    final pago = normalize(pagoDirecto, best: 90, worst: 30);
    final pagoTiempo = normalize(tiempoPromedioPago, best: 24, worst: 120, inverse: true);
    final entrega = normalize(tiempoEntrega, best: 24, worst: 48, inverse: true);
    return (3 * pago + pagoTiempo + 2 * entrega) / 6;
  }

  double get economicScore {
    return normalize(puntualidad, best: 100, worst: 60);
  }

  double get s3Score {
    const wEnv = 0.4;
    const wSoc = 0.3;
    const wEco = 0.3;
    return envScore * wEnv + socialScore * wSoc + economicScore * wEco;
  }
}

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

// --- DATOS MOCK ACTUALIZADOS CON TENDENCIAS ---

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
    categories: [ProductCategory.papa, ProductCategory.destacado],
    minOrderKg: 5,
    trend: PriceTrend.rising, // La papa sube (Escasez)
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
    categories: [ProductCategory.papa],
    minOrderKg: 5,
    trend: PriceTrend.stable, // Huayro estable
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
    categories: [ProductCategory.temporada],
    minOrderKg: 2,
    trend: PriceTrend.falling, // Mango baja (Entra temporada)
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
    categories: [ProductCategory.aderezo],
    minOrderKg: 1,
    trend: PriceTrend.rising, // Ajo sube
  ),
  Product(
    name: 'Ají amarillo',
    imageUrl: 'assets/products/aji-amarillo.png',
    pricePerKg: 1.00,
    rating: 4.5,
    mermasEvitadas: 20,
    co2KgPorKg: 0.9,
    pagoDirecto: 75,
    tiempoPromedioPago: 48,
    tiempoEntrega: 22,
    puntualidad: 92,
    categories: [ProductCategory.aderezo, ProductCategory.temporada],
    minOrderKg: 1,
    trend: PriceTrend.falling, // Ají baja
  ),
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
    categories: [ProductCategory.aderezo],
    minOrderKg: 3,
    trend: PriceTrend.stable, // Cebolla estable
  ),

  // 🍋 Limón Sutil (El "Dolor de cabeza" de los restaurantes)
  Product(
    name: 'Limón Sutil',
    imageUrl: 'assets/products/limon-sutil.png', // Asegúrate de tener una imagen o usa un placeholder
    pricePerKg: 5.50,
    rating: 4.9,
    mermasEvitadas: 25,
    co2KgPorKg: 0.6,
    pagoDirecto: 85,       // Alto impacto social en Piura/Olmos
    tiempoPromedioPago: 24,
    tiempoEntrega: 18,
    puntualidad: 98,
    categories: [ProductCategory.temporada, ProductCategory.destacado],
    minOrderKg: 1,        // Pedido mínimo alto por rotación
    trend: PriceTrend.rising, // ¡Alerta! El limón está subiendo
  ),

  // 🥑 Palta Fuerte (Oportunidad de compra)
  Product(
    name: 'Palta Fuerte',
    imageUrl: 'assets/products/palta-fuerte.png',
    pricePerKg: 4.90,
    rating: 4.7,
    mermasEvitadas: 15,    // Producto delicado
    co2KgPorKg: 1.1,
    pagoDirecto: 80,
    tiempoPromedioPago: 48,
    tiempoEntrega: 24,
    puntualidad: 95,
    categories: [ProductCategory.temporada, ProductCategory.destacado],
    minOrderKg: 2,
    trend: PriceTrend.falling, // ¡Bajada de precio! Buen momento para causas
  ),

  // 🌶️ Ají Panca (Básico para aderezos/anticuchos)
  Product(
    name: 'Ají Panca',
    imageUrl: 'assets/products/aji-panca.png',
    pricePerKg: 3.50,
    rating: 4.4,
    mermasEvitadas: 28,    // Muy resistente
    co2KgPorKg: 0.5,
    pagoDirecto: 65,
    tiempoPromedioPago: 60,
    tiempoEntrega: 48,
    puntualidad: 90,
    categories: [ProductCategory.aderezo],
    minOrderKg: 1,
    trend: PriceTrend.stable,
  ),

  // 🍠 Camote Amarillo (Guarnición económica)
  Product(
    name: 'Camote Amarillo',
    imageUrl: 'assets/products/camote.png',
    pricePerKg: 1.20,
    rating: 4.3,
    mermasEvitadas: 12,
    co2KgPorKg: 0.4,
    pagoDirecto: 60,
    tiempoPromedioPago: 36,
    tiempoEntrega: 24,
    puntualidad: 88,
    categories: [ProductCategory.oferta, ProductCategory.temporada],
    minOrderKg: 2,        // Se mueve por volumen
    trend: PriceTrend.stable,
  ),
];

