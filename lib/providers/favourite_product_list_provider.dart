import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/services/favourite_products_service.dart';

//Clase que maneja el contexto global de los productos en favoritos
class FavouriteProductListProvider with ChangeNotifier{
  final favouriteProductService = FavoutiteProductsService(); //servicio de productos en favoritos
  final List<ProductModel> _favouriteProductList = []; //lista de productos en favoritos

  //Obtiene todos los productos en favoritos de la BBDD y lo asigna a la variable local
  Future<List<ProductModel>> getFavouriteProducts(int userAuthenticatedId) async{
    _favouriteProductList.clear(); //limpia la lista
    _favouriteProductList.addAll( //añade todos los productos a la lista
      await favouriteProductService.getAllFavouriteProducts(userAuthenticatedId)
    );

    notifyListeners(); //notofica a los oyentes
    return _favouriteProductList;

  }

  //Método que añade un producto en favorito
  Future<void> addFavouriteProduct(int userId, int productId) async {
    ProductModel? productModel = await favouriteProductService.addFavouriteProduct(userId, productId);
    //Busca que el producto se haya insertado correctamente en la BBDD y que no existe el id en la lista
    if (productModel != null && !_favouriteProductList.any((product) => product.id == productId)) {
      _favouriteProductList.add(productModel); //añade el producto a la lista de favoritos
      notifyListeners();  // Notifica solo si el producto es añadido
    }
  }

  //Método que elimina un producto de la lista de favoritos
  Future<void> removeFavouriteProduct(int userId, int productId) async {
    //elimina el producto de la lista en la BBDD
    bool removed = await favouriteProductService.removeFavouriteProduct(userId, productId);
    if (removed) { //si se ha eliminado
      _favouriteProductList.removeWhere((product) => product.id == productId); //lo elimina de la lista
      notifyListeners();  // Notifica solo si el producto fue eliminado
    }
  }

  //Getter
  List<ProductModel> get getFavouriteProductList => _favouriteProductList;
}