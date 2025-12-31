import 'package:get/get.dart';

class ProductController extends GetxController {
  // Mapa de productos por categoría
  final RxMap<String, List<Map<String, dynamic>>> productsByCategory = <String, List<Map<String, dynamic>>>{
    'Aceitunas': [
      {'name': 'Aceituna Serpis negra sin hueso (75 g)', 'price': 1.50, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Aceituna negra de calidad superior'},
      {'name': 'Aceituna Serpis rellena de anchoa (3×130 g)', 'price': 3.99, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Clásica rellena de anchoa'},
      {'name': 'Aceituna Serpis rodajas verdes (170 g)', 'price': 1.80, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Ideal para ensaladas'},
      {'name': 'Aceituna Serpis sabor jalapeño (130 g)', 'price': 2.10, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Toque picante'},
      {'name': 'Aceituna verde Cano (bolsa)', 'price': 5.50, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Disponible con o sin hueso'},
      {'name': 'Alcaparras Asperio / La Fragua', 'price': 2.20, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Perfectas para aderezar'},
      {'name': 'Altramuces La Fragua', 'price': 1.90, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Aperitivo clásico'},
      {'name': 'Banderillas Cano y La Fragua', 'price': 3.00, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Dulces y picantes'},
      {'name': 'Berenjenas Almagreña', 'price': 4.50, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Aliñadas, embuchadas o troceadas'},
      {'name': 'Berenjenas Antonio', 'price': 4.20, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Disponible en tarro y lata'},
    ],
    'Snacks': [
      {'name': 'Roscos de naranja El Dorao', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcar'},
      {'name': 'Sobaos Codan', 'price': 2.90, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcares añadidos'},
      {'name': 'Tartaletas Naturceliac', 'price': 4.20, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Chocolate y frambuesa'},
      {'name': 'Tortas de aceite', 'price': 3.80, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcar / integrales'},
      {'name': 'Palmeras y palmeritas', 'price': 2.50, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Opción sin azúcar'},
      {'name': 'Pastas Tito', 'price': 3.20, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcar'},
      {'name': 'Molletes y bollería Naturceliac', 'price': 4.00, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Variedad sin gluten'},
    ],
    'Bebidas y Cocina': [
      {'name': 'Jarras (500 ml, 1 L, 1,5 L)', 'price': 5.00, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Varios tamaños'},
      {'name': 'Hervidor de verduras inox', 'price': 15.90, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Acero inoxidable'},
      {'name': 'Jamoneros de madera', 'price': 25.00, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Soporte robusto'},
      {'name': 'Filtros de infusión', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Malla fina'},
      {'name': 'Flaneras', 'price': 4.00, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Moldes individuales'},
      {'name': 'Hueveras', 'price': 2.90, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Plástico resistente'},
      {'name': 'Hornillo de gas portátil', 'price': 19.99, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Ideal camping'},
    ],
    'Menaje': [
      {'name': 'Cazuelas Vitro Azofra', 'price': 18.00, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Medidas 24 a 40 cm'},
      {'name': 'Platos de postre', 'price': 2.50, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Vidrio y cerámica'},
      {'name': 'Centros de mesa', 'price': 12.00, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Decorativos'},
      {'name': 'Centrífugas de ensalada', 'price': 8.50, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Secado rápido'},
      {'name': 'Porrones', 'price': 6.00, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Tradicionales'},
      {'name': 'Porta fotos', 'price': 5.00, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Varios diseños'},
      {'name': 'Pongotodo con tapa', 'price': 7.50, 'image': 'https://images.unsplash.com/photo-1590701833281-e6283af0948d?w=600&q=80', 'description': 'Almacenaje multiusos'},
    ],
    'Fiambreras': [
      {'name': 'Fiambreras redondas', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Varios tamaños y litros'},
      {'name': 'Fiambreras térmicas', 'price': 12.90, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Mantienen temperatura'},
      {'name': 'Fiambreras rectangulares', 'price': 5.50, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Tamaño familiar'},
      {'name': 'Packs apilables', 'price': 8.90, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Ahorra espacio'},
    ],
    'Decoración': [
      {'name': 'Figuras decorativas', 'price': 9.99, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Budas, animales, cactus, flores'},
      {'name': 'Floreros', 'price': 14.50, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Cerámica, decorativos, animales'},
      {'name': 'Centros decorativos', 'price': 18.00, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Elegantes'},
      {'name': 'Popurrí', 'price': 4.50, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Sólido y líquido'},
    ],
    'Ambientadores': [
      {'name': 'Ambientadores Mikado', 'price': 6.50, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Ámbar, frutas, flores'},
      {'name': 'Ambientadores spray', 'price': 2.90, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Acción rápida'},
      {'name': 'Ambientadores coche', 'price': 1.99, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Frescura en movimiento'},
      {'name': 'Perlas perfumadas', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Larga duración'},
      {'name': 'Esencias concentradas', 'price': 4.90, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Máxima intensidad'},
    ],
    'Insecticidas': [
      {'name': 'Insecticidas Bloom', 'price': 4.50, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Aerosol, líquido, recambios'},
      {'name': 'Antipolillas', 'price': 3.20, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Orion / Orphea'},
      {'name': 'Cebos', 'price': 5.50, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Para hormigas y cucarachas'},
      {'name': 'Insecticidas jardín y hogar', 'price': 6.90, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Protección total'},
    ],
    'Piscinas': [
      {'name': 'Cloro', 'price': 12.00, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Tabletas, grano, choque'},
      {'name': 'Algicidas', 'price': 8.50, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Previene algas'},
      {'name': 'Floculantes', 'price': 7.90, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Clarificador'},
      {'name': 'Incrementador de pH', 'price': 6.50, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Equilibrio del agua'},
      {'name': 'Accesorios limpieza', 'price': 15.00, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Limpiafondos, mangueras, pértigas'},
      {'name': 'Kits de mantenimiento', 'price': 25.00, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Todo en uno'},
    ],
  }.obs;

  // Añadir un nuevo producto customizado
  void addProduct(String category, String name, String description, double price, String imagePath) {
    if (!productsByCategory.containsKey(category)) {
      productsByCategory[category] = [];
    }
    
    productsByCategory[category]!.insert(0, {
      'name': name,
      'price': price,
      'image': imagePath, // Puede ser asset local o URL
      'description': description,
    });
    
    productsByCategory.refresh(); // Forzar actualización de UI si es necesario
  }
}
