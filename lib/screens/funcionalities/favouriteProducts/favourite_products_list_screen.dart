import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/favourite_product_list_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/ProductDetailsOverview/product_details_overview_screen.dart';
import 'package:provider/provider.dart';

// Screen que contiene la lista de productos en favoritos
class FavouriteProductListScreen extends StatefulWidget {
  const FavouriteProductListScreen({super.key});

  @override
  State<FavouriteProductListScreen> createState() => _FavouriteProductListScreenState();
}

class _FavouriteProductListScreenState extends State<FavouriteProductListScreen> {
  List<ProductModel> displayedFavoriteProductList = [];
  Set<int> favoriteIds = {}; // Mantiene los IDs de productos favoritos localmente
  bool isLoading = true; // Para gestionar el estado de carga

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts(); // Carga los productos favoritos cuando se inicia la pantalla
  }

  // Método para cargar los productos favoritos
  Future<void> _loadFavoriteProducts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userAuthenticatedId = userProvider.getUserAuthenticatedId;

    if (userAuthenticatedId != null) {
      // Obtener productos favoritos del proveedor
      List<ProductModel> favoriteProductList = await Provider.of<FavouriteProductListProvider>(context, listen: false)
          .getFavouriteProducts(userAuthenticatedId);

      // Actualizar lista local para la visualización sin afectarla directamente en el proveedor
      setState(() {
        displayedFavoriteProductList = List.from(favoriteProductList); // Copia de la lista original
        favoriteIds = displayedFavoriteProductList.map((product) => product.id).toSet();
        isLoading = false; // Indicar que la carga ha terminado
      });
    } else {
      setState(() {
        isLoading = false; // En caso de no haber usuario autenticado, también terminamos el estado de carga
      });
    }
  }

  // Gestiona el añadir/eliminar producto de favoritos
  void _manageFavorite(ProductModel product) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userAuthenticatedId = userProvider.getUserAuthenticatedId;

    if (userAuthenticatedId != null) {
      final favouriteProvider = Provider.of<FavouriteProductListProvider>(context, listen: false);
      final isFavourite = favoriteIds.contains(product.id); //si es true, el producto está en favoritos

      if (isFavourite) {
        await favouriteProvider.removeFavouriteProduct(userAuthenticatedId, product.id); //elimina de favoritos
        favoriteIds.remove(product.id); // Solo actualiza el ícono localmente
      } else {
        await favouriteProvider.addFavouriteProduct(userAuthenticatedId, product.id); //añade a favoritos
        favoriteIds.add(product.id); //añade el id del producto añadido a la lista
      }

      // Actualiza la lista local sin eliminar el producto
      setState(() {}); // Actualiza el ícono sin remover el producto de la lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        leading: IconButton(
          onPressed: () {
            Provider.of<BottomIndexNavigationProvider>(context, listen: false).setIndex = 0;
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: isLoading // muestra una barra de progreso circular mientras cargan los datos
          ? const Center(child: CircularProgressIndicator(color: Colors.lightBlue)) // Cargando
          : RefreshIndicator(
              onRefresh: _loadFavoriteProducts, // vuelve a cargar la lista de favoritos
              color: Colors.blue,
              backgroundColor: Colors.white,
              child: displayedFavoriteProductList.isEmpty
                  ? const Center(
                      child: Text(
                        "No has añadido ningún producto a favoritos",
                        style: TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey
                        )
                      )
                    )
                  : ListView.builder( //se construye el ListView con los productos en favoritos
                      itemCount: displayedFavoriteProductList.length,
                      itemBuilder: (context, index) {
                        final product = displayedFavoriteProductList[index];
                        final isFavourite = favoriteIds.contains(product.id);
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navega a los detalles del producto seleccionado
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ProductDetailsScreen(seledtedProductId: product.id)),
                              );
                            },
                            child: Row(
                              children: [
                                // Imagen del producto
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: product.images.isNotEmpty &&
                                            product.images.where((image) => image != null).isNotEmpty
                                        ? FadeInImage.assetNetwork(
                                            placeholder: 'images/loading_v1.gif', //gif de carga
                                            placeholderCacheWidth: 120,
                                            placeholderCacheHeight: 120,
                                            placeholderFit: BoxFit.scaleDown,
                                            image: product.images.firstWhere((image) => image != null)!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            imageErrorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'images/damagedFile.jpg', //imagen de error
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'images/eyes4.jpg', // Imagen predeterminada
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Detalles del producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.price} €',
                                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      // Icono de favorito
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () => _manageFavorite(product),
                                          child: Icon(
                                            isFavourite ? Icons.favorite : Icons.favorite_border,
                                            color: isFavourite ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
