import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/services/favourite_products_service.dart';
import 'package:prime_store/services/product_service.dart';

class ProductListProvider with ChangeNotifier{
  final productService = ProductService();
  final favouriteProductService = FavoutiteProductsService();
  List<ProductModel> _productOnSaleListProvider = [];
  List<ProductModel> _productUserOnSaleList = [];

  Future<List<ProductModel>> retrieveProductsOnSale(int userAuthenticatedId) async{
    _productOnSaleListProvider.clear();
    _productOnSaleListProvider.addAll(await productService.getAllOnSaleProducts(userAuthenticatedId)); //!cambiar por el id del usuario desde provider
    notifyListeners();
    return _productOnSaleListProvider;
  }

  Future<List<ProductModel>> retrieveUserProductsOnSale(int userAuthenticatedId) async{
    _productUserOnSaleList.clear();
    _productUserOnSaleList.addAll(await productService.getAllOnSaleProductsFromIdUser(userAuthenticatedId)); //!cambiar por el id del usuario desde provider
    notifyListeners();
    return _productUserOnSaleList;
  }

  Future<ProductModel> getProductById(int id){
    return productService.getProductById(id);
  }

  Future<ProductModel> updateProduct(ProductModel productModel) async {
  // Realizar la actualización del producto a través del servicio
    ProductModel? updatedProduct = await productService.updateProduct(productModel);

    // Verificar si el producto actualizado existe
    if (updatedProduct != null) {
      // Buscar el índice del producto en la lista _productOnSaleListProvider
      int index = _productUserOnSaleList.indexWhere((product) => product.id == updatedProduct.id);
      
      // Si se encuentra el producto, reemplazarlo con el producto actualizado
      if (index != -1) {
        _productUserOnSaleList[index] = updatedProduct;
      }

      // Notificar a los oyentes para que la UI se actualice
      
    }
    notifyListeners();

    return updatedProduct!;
  }

  Future<void>deleteProductById(int id) async{
    try{
      await productService.deleteProductById(id);
      int index  = _productUserOnSaleList.indexWhere((product) => product.id == id);
      if(index != -1){
        _productUserOnSaleList.removeAt(index);
        notifyListeners();
      }
    }on DioException {
      rethrow;
    }
  }

  /* ProductModel getContainingPoductFromList(ProductModel productModel){
    return _productUserOnSaleList.firstWhere((product) => product.id == productModel.id);
  } */

  List<ProductModel> get getProductOnSaleList => _productOnSaleListProvider;
  List<ProductModel> get getUserProductOnSaleList => _productUserOnSaleList;

  set setProductOnSaleList(List<ProductModel> productList){
    _productOnSaleListProvider = productList;
    notifyListeners();
  }

  set setUserProductOnSaleList(List<ProductModel> productList){
    _productUserOnSaleList = productList;
    notifyListeners();
  }
}