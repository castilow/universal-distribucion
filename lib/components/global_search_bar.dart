import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/screens/home/controller/home_controller.dart';
import 'package:chat_messenger/controllers/product_controller.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/components/cached_image_with_retry.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_messenger/tabs/products/add_product_screen.dart';

class GlobalSearchBar extends StatefulWidget {
  final bool showInHeader;
  final VoidCallback? onSearchActivated;
  final VoidCallback? onSearchDeactivated;

  const GlobalSearchBar({
    Key? key,
    this.showInHeader = false,
    this.onSearchActivated,
    this.onSearchDeactivated,
  }) : super(key: key);

  @override
  State<GlobalSearchBar> createState() => GlobalSearchBarState();
}

class GlobalSearchBarState extends State<GlobalSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  List<User> _searchResults = [];
  List<User> _allUsers = [];
  List<Map<String, dynamic>> _productResults = [];
  bool _isLoading = false;
  bool _isSearchingProducts = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _debounceTimer; // Para debounce en búsqueda de productos
  
  // Getter para acceder al controller desde fuera
  TextEditingController get textController => _textController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUsers();
    _textController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await UserApi.getAllUsers();
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _textController.text.trim();
    
    // Verificar si estamos en la pantalla de productos
    bool isProductsPage = false;
    try {
      final homeController = Get.find<HomeController>();
      isProductsPage = homeController.pageIndex.value == 3; // ProductsScreen está en index 3
      
      // Actualizar el estado si cambió
      if (_isSearchingProducts != isProductsPage && mounted) {
        setState(() {
          _isSearchingProducts = isProductsPage;
        });
      }
    } catch (e) {
      if (_isSearchingProducts && mounted) {
        setState(() {
          _isSearchingProducts = false;
        });
      }
    }
    
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _productResults.clear();
      });
      // Limpiar búsqueda de productos
      if (isProductsPage) {
        try {
          final productController = Get.find<ProductController>();
          productController.clearSearch();
        } catch (e) {
          // Ignorar
        }
      }
      return;
    }

    // Si estamos en productos, buscar productos con debounce para mejor rendimiento
    if (isProductsPage) {
      // Cancelar timer anterior
      _debounceTimer?.cancel();
      
      // Crear nuevo timer con debounce de 300ms para mejor rendimiento
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        try {
          final productController = Get.find<ProductController>();
          productController.setSearchQuery(query);
          
          // Actualizar productos localmente también para mantener sincronizado
          final filteredProducts = productController.filteredProducts;
          if (mounted) {
            setState(() {
              _productResults = filteredProducts;
              _searchResults.clear();
            });
          }
        } catch (e) {
          debugPrint('Error buscando productos: $e');
          if (mounted) {
            setState(() {
              _productResults.clear();
            });
          }
        }
      });
      return;
    }

    // Búsqueda normal de usuarios
    if (query.startsWith('@')) {
      // Buscar solo por username
      final usernameQuery = query.substring(1).toLowerCase();
      final results = _allUsers.where((user) =>
        user.username.toLowerCase().contains(usernameQuery)
      ).toList();
      setState(() {
        _searchResults = results;
        _productResults.clear();
      });
    } else {
      // Buscar por nombre, username o email
      final results = _allUsers.where((user) =>
        user.fullname.toLowerCase().contains(query.toLowerCase()) ||
        user.username.toLowerCase().contains(query.toLowerCase()) ||
        user.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
      setState(() {
        _searchResults = results;
        _productResults.clear();
      });
    }
  }

  void activateSearch() {
    setState(() {
      _isSearching = true;
    });
    
    _animationController.forward();
    _focusNode.requestFocus();
    
    // Notificar al padre que se activó la búsqueda
    widget.onSearchActivated?.call();
  }

  void _activateSearch() {
    activateSearch();
  }

  void _deactivateSearch() {
    setState(() {
      _isSearching = false;
      _textController.clear();
      _searchResults.clear();
      _productResults.clear();
    });
    
    // Limpiar búsqueda de productos
    try {
      final productController = Get.find<ProductController>();
      productController.clearSearch();
    } catch (e) {
      // Ignorar si no existe
    }
    
    _animationController.reverse();
    _focusNode.unfocus();
    
    // Notificar al padre que se desactivó la búsqueda
    widget.onSearchDeactivated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    if (widget.showInHeader) {
      if (_isSearching) {
        // Modo de búsqueda activo - barra expandida
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Botón de regreso
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: _deactivateSearch,
              ),
              
              // Barra de búsqueda expandida
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _widthAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? const Color(0xFF2A2A2A) 
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(22),
                            border: isDarkMode
                                ? Border.all(
                                    color: const Color(0xFF404040).withOpacity(0.6),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: _isSearchingProducts ? 'Buscar productos...' : 'Buscar usuarios y conversaciones',
                              hintStyle: TextStyle(
                                color: isDarkMode 
                                    ? const Color(0xFF9CA3AF) 
                                    : const Color(0xFF64748B),
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: isDarkMode 
                                    ? const Color(0xFF9CA3AF) 
                                    : const Color(0xFF64748B),
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        // Modo normal - barra compacta
        return GestureDetector(
          onTap: _activateSearch,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: isDarkMode
                  ? Border.all(
                      color: const Color(0xFF404040).withOpacity(0.6),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  color: isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    // Verificar si estamos en productos
                    try {
                      final homeController = Get.find<HomeController>();
                      final isProducts = homeController.pageIndex.value == 3;
                      return Text(
                        isProducts ? 'Buscar productos...' : 'Buscar',
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    } catch (e) {
                      return Text(
                        'Buscar',
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return Container();
  }

  // Método para obtener el contenido de búsqueda (para usar en el padre)
  Widget buildSearchContent() {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? Colors.white : Colors.blue,
        ),
      );
    }

    final query = _textController.text.trim();
    if (query.isEmpty) {
      return _buildEmptyState();
    }

    // Usar Obx solo para detectar cambios en la página y productos
    return Obx(() {
      // Verificar si estamos en la pantalla de productos
      bool isProductsPage = false;
      try {
        final homeController = Get.find<HomeController>();
        isProductsPage = homeController.pageIndex.value == 3; // ProductsScreen está en index 3
      } catch (e) {
        // Ignorar
      }

      // Si estamos buscando productos
      if (isProductsPage) {
        try {
          final productController = Get.find<ProductController>();
          final filteredProducts = productController.filteredProducts;
          
          if (filteredProducts.isEmpty) {
            return _buildNoProductResults();
          }
          
          return _buildProductSearchResultsWithProducts(filteredProducts, isDarkMode);
        } catch (e) {
          debugPrint('Error en buildSearchContent para productos: $e');
          if (_productResults.isEmpty) {
            return _buildNoProductResults();
          }
          return _buildProductSearchResults(isDarkMode);
        }
      }

      // Búsqueda normal de usuarios (fuera del Obx ya que no necesita reactividad)
      if (_searchResults.isEmpty) {
        return _buildNoResults();
      }

      return _buildSearchResults();
    });
  }

  Widget _buildEmptyState() {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    // Verificar si estamos en productos
    bool isProductsPage = false;
    try {
      final homeController = Get.find<HomeController>();
      isProductsPage = homeController.pageIndex.value == 3;
    } catch (e) {
      isProductsPage = false;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProductsPage ? IconlyLight.bag : Icons.search,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isProductsPage ? 'Busca productos' : 'Busca conversaciones y usuarios',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isProductsPage 
              ? 'Escribe el nombre del producto para buscar'
              : 'Escribe @username para buscar usuarios específicos',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductResults() {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.bag,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchResults(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _productResults.length,
      itemBuilder: (context, index) {
        final product = _productResults[index];
        return _buildProductTile(product, isDarkMode);
      },
    );
  }

  Widget _buildProductSearchResultsWithProducts(List<Map<String, dynamic>> products, bool isDarkMode) {
    // Lista de productos sin contador - más limpia con mucho más espacio arriba
    return ListView.builder(
      padding: const EdgeInsets.only(top: 72, bottom: 20, left: 16, right: 16),
      itemCount: products.length,
      // Mejora de rendimiento: solo renderiza los items visibles
      cacheExtent: 500,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductTile(product, isDarkMode);
      },
    );
  }

  Widget _buildProductTile(Map<String, dynamic> product, bool isDarkMode) {
    final goldColor = const Color(0xFFD4AF37);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
             // Show preview instead of just closing
             _showProductPreview(product, isDarkMode);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen del producto
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: product['image'] != null && product['image'].toString().isNotEmpty
                      ? (product['image'].toString().startsWith('http')
                          ? CachedImageWithRetry(
                              imageUrl: product['image'],
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey[100],
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: goldColor,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: Icon(
                                IconlyLight.image, 
                                color: isDarkMode ? Colors.white24 : Colors.grey[300],
                                size: 28,
                              ),
                            )
                          : Image.file(
                              File(product['image']),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                IconlyLight.image, 
                                color: isDarkMode ? Colors.white24 : Colors.grey[300],
                                size: 28,
                              ),
                            ))
                      : Icon(
                          IconlyLight.image, 
                          color: isDarkMode ? Colors.white24 : Colors.grey[300],
                          size: 28,
                        ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Producto',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product['category'] != null && product['category'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: goldColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product['category'].toString().toUpperCase(),
                            style: TextStyle(
                              color: goldColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '€${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    if (product['quantity'] != null && (product['quantity'] as int) > 0)
                      Text(
                        'Stock: ${product['quantity']}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white38 : Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserTile(_searchResults[index], isDarkMode);
      },
    );
  }

  Widget _buildUserTile(User user, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1E1E1E) 
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF404040) 
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CachedCircleAvatar(
          imageUrl: user.photoUrl,
          radius: 24,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        ),
        title: Text(
          user.fullname.isNotEmpty ? user.fullname : 'Usuario',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          user.username.isNotEmpty ? '@${user.username}' : 'Sin username',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: user.isOnline 
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: 2,
                ),
              ),
            )
          : null,
        onTap: () {
          _deactivateSearch();
          Get.toNamed(
            AppRoutes.profileView,
            arguments: {
              'user': user,
              'isGroup': false,
            },
          );
        },
      ),
    );
  }

  // Getter para verificar si está en modo búsqueda
  bool get isSearching => _isSearching;

  void _showProductPreview(Map<String, dynamic> product, bool isDarkMode) {
    const goldColor = Color(0xFFD4AF37);
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141414) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.transparent,
              width: 1,
            ),
             boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Image Section (Floating Look)
              Stack(
                children: [
                   Container(
                      height: 280,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        gradient: isDarkMode 
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.grey[900]!, const Color(0xFF141414)],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.grey[100]!, Colors.white],
                            ),
                      ),
                      child: Hero(
                        tag: 'product_${product['productId']}', 
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: product['image'] != null && product['image'].toString().isNotEmpty
                              ? (product['image'].toString().startsWith('http')
                                  ? CachedImageWithRetry(
                                      imageUrl: product['image'],
                                      fit: BoxFit.cover,
                                      placeholder: Center(
                                        child: CircularProgressIndicator(color: goldColor, strokeWidth: 2),
                                      ),
                                      errorWidget: _buildPlaceholder(goldColor, isDarkMode),
                                    )
                                  : Image.file(File(product['image']), fit: BoxFit.cover, errorBuilder: (_,__,___) => _buildPlaceholder(goldColor, isDarkMode)))
                              : _buildPlaceholder(goldColor, isDarkMode),
                          ),
                        ),
                      ),
                  ),
                  
                  // Close Button (Glassmorphism)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black87, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 2. Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: goldColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: goldColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        product['category']?.toString().toUpperCase() ?? 'GENERAL',
                        style: GoogleFonts.inter(
                          color: goldColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      product['name'] ?? 'Producto Sin Nombre',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price (Large & Modern)
                    Text(
                      '€${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.0,
                      ),
                    ),
                     
                    const SizedBox(height: 24),
                    
                    // Stats Divider
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey[50], // Very subtle background
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPremiumStat(
                            'Stock Disponible',
                            '${product['quantity'] ?? 0}',
                            IconlyBold.chart,
                            isDarkMode,
                          ),
                           Container(width: 1, height: 30, color: isDarkMode ? Colors.white12 : Colors.grey[200]),
                          _buildPremiumStat(
                            'Referencia',
                            '#${product['productId']?.toString().substring(0, 4) ?? "---"}',
                            IconlyBold.scan,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Premium Button
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFC5A028)], // Richer Gold Gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.back(); 
                            _deactivateSearch();
                            Get.to(() => AddProductScreen(product: product));
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(IconlyBold.edit, color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'Editar Producto',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.75), // Darker barrier
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeOutQuart,
    );
  }
  
  Widget _buildPlaceholder(Color color, bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
      child: Center(
        child: Icon(IconlyLight.image, color: color.withOpacity(0.5), size: 48),
      ),
    );
  }

  Widget _buildPremiumStat(String label, String value, IconData icon, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: isDarkMode ? Colors.white54 : Colors.grey[400], size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: isDarkMode ? Colors.white30 : Colors.grey[400],
            fontSize: 11, // Smaller, uppercase-style label
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} // End of GlobalSearchBarState



