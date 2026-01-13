import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/api/category_api.dart';
import 'package:chat_messenger/controllers/product_controller.dart';
import 'package:chat_messenger/tabs/products/add_category_screen.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const goldColor = Color(0xFFD4AF37);
    final currentUser = AuthController.instance.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF000000) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 0,
        title: const Text(
          'Gestionar Categorías',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CategoryApi.getCategoriesStream().handleError((error) {
          debugPrint('❌ Error en getCategoriesStream: $error');
          return <Map<String, dynamic>>[];
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: goldColor,
              ),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            final isPermissionError = error.contains('permission-denied');
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPermissionError 
                          ? 'Error de Permisos'
                          : 'Error al cargar categorías',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPermissionError
                          ? 'Las reglas de Firestore no están desplegadas.\n\nPor favor, despliega las reglas ejecutando:\n\nfirebase deploy --only firestore:rules'
                          : 'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          
          // Filtrar solo las categorías del usuario actual
          final userCategories = categories.where((cat) {
            return cat['userId'] == currentUser.userId;
          }).toList();

          if (userCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconlyLight.category,
                    size: 64,
                    color: isDarkMode ? Colors.white54 : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes categorías creadas',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userCategories.length,
            itemBuilder: (context, index) {
              final category = userCategories[index];
              final imageUrl = category['image'] ?? category['imageUrl'] ?? '';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: goldColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[200],
                    ),
                    child: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: goldColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                IconlyLight.image,
                                color: isDarkMode ? Colors.white54 : Colors.grey[600],
                              ),
                            ),
                          )
                        : Icon(
                            IconlyLight.category,
                            color: goldColor,
                            size: 28,
                          ),
                  ),
                  title: Text(
                    category['name'] ?? 'Sin nombre',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón editar
                      IconButton(
                        icon: Icon(
                          IconlyLight.edit,
                          color: goldColor,
                          size: 20,
                        ),
                        onPressed: () async {
                          await Get.to(() => AddCategoryScreen(category: category));
                        },
                      ),
                      // Botón eliminar
                      IconButton(
                        icon: Icon(
                          IconlyLight.delete,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () async {
                          // Mostrar confirmación
                          final confirm = await Get.dialog<bool>(
                            AlertDialog(
                              backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                              title: Text(
                                'Eliminar Categoría',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              content: Text(
                                '¿Estás seguro de que quieres eliminar la categoría "${category['name']}"?',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.back(result: true),
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              final categoryId = category['id'] ?? category['categoryId'];
                              await CategoryApi.deleteCategory(categoryId);
                              
                              final productController = Get.find<ProductController>();
                              await productController.refreshProducts();

                              Get.snackbar(
                                'Éxito',
                                'Categoría eliminada correctamente',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Error al eliminar la categoría: $e',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const AddCategoryScreen());
        },
        backgroundColor: goldColor,
        child: const Icon(
          IconlyBold.plus,
          color: Colors.black,
        ),
      ),
    );
  }
}
