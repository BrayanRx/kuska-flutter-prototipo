import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kuska_prototipos/product.dart';
import 'package:kuska_prototipos/cart.dart';

class KuskaIntelligenceService {
  // ⚠️ RECUERDA PONER TU API KEY
  static const String _apiKey = 'AIzaSyAlKR_Jq6cBPbTR3QH2LDW9rinsOKm7Lkw'; 

  final GenerativeModel _model;

  KuskaIntelligenceService()
      : _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

  Future<List<Map<String, dynamic>>> processOrderRequest(String userPrompt) async {
    final availableProducts = mockProducts.map((e) => e.name).join(', ');

    final prompt = '''
      Actúa como un experto Jefe de Logística.
      Interpreta la necesidad del usuario y conviértela en una orden de compra precisa usando SOLO el catálogo disponible.

      Catálogo disponible: [$availableProducts].

      Reglas:
      1. Si pide un PLATO o EVENTO (ej: "Lomo saltado"), desglosa los ingredientes necesarios (solo los que vendemos).
      2. Si pide ingredientes directos, respeta su pedido.
      3. SOLO sugiere productos exactos del catálogo.
      4. Cantidades en KG (números).

      Formato OBLIGATORIO: JSON Array puro. 
      Ejemplo: [{"productName": "Papa amarilla", "quantity": 10.5}]
      
      Pedido: "$userPrompt"
    ''';

    try {
      final content = [Content.text(prompt)];
      print("⏳ Enviando prompt a Gemini...");
      
      final response = await _model.generateContent(content);
      String? responseText = response.text;
      
      print("🤖 Respuesta cruda de Gemini: $responseText"); // ¡MIRA ESTO EN CONSOLA!

      if (responseText == null) throw Exception("Gemini no respondió nada.");

      // --- LIMPIEZA QUIRÚRGICA DEL JSON ---
      // Buscamos dónde empieza el array '[' y dónde termina ']'
      final startIndex = responseText.indexOf('[');
      final endIndex = responseText.lastIndexOf(']');

      if (startIndex == -1 || endIndex == -1) {
        throw Exception("No se encontró un JSON array en la respuesta.");
      }

      // Extraemos solo lo que está entre corchetes
      final jsonString = responseText.substring(startIndex, endIndex + 1);
      
      // Parseo
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      return jsonList.map((e) => {
        'productName': e['productName'].toString(),
        'quantity': double.parse(e['quantity'].toString()),
      }).toList();

    } catch (e) {
      print("❌ ERROR CRÍTICO EN KUSKA AI: $e");
      return [];
    }
  }

  Future<bool> executeOrder(String userPrompt) async {
    final items = await processOrderRequest(userPrompt);
    if (items.isEmpty) return false;

    final cart = Cart.instance;
    
    // Contador para saber si realmente agregamos algo
    int itemsAdded = 0;

    for (var item in items) {
      try {
        // Normalizamos strings para búsqueda flexible
        final nameFromAI = item['productName'].toString().toLowerCase().trim();
        
        final product = mockProducts.firstWhere(
          (p) {
             final pName = p.name.toLowerCase();
             return pName == nameFromAI || pName.contains(nameFromAI) || nameFromAI.contains(pName);
          },
        );

        // --- LÓGICA DE AJUSTE DE MÍNIMOS (AUTO-FIX) ---
        double qtyRequest = double.parse(item['quantity'].toString());
        double finalQty = qtyRequest;

        // Si lo que pide la IA es menor al mínimo del producto, usamos el mínimo.
        if (qtyRequest < product.minOrderKg) {
          print("⚠️ Ajustando cantidad de ${product.name}: Pedido $qtyRequest kg -> Mínimo ${product.minOrderKg} kg");
          finalQty = product.minOrderKg;
        }

        cart.addProduct(product, finalQty);
        print("✅ Producto agregado: ${product.name} ($finalQty kg)");
        itemsAdded++;

      } catch (e) {
        print("⚠️ Producto sugerido no encontrado en catálogo: ${item['productName']}");
      }
    }
    
    // Retornamos true solo si al menos un producto se pudo agregar
    return itemsAdded > 0;
  }
}