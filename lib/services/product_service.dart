import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class ProductService {
  final Dio _dio = Dio();
  final _secureStorage  = const FlutterSecureStorage();

  Future<List<ProductModel>> getAllOnSaleProducts(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/productsOnSale/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data =  response.data;
        List<ProductModel> productList = data.map((product) => ProductModel.fromJson(product)).toList();
        return productList;

      }else{
        throw 'Error al obtener la lista de productos: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<List<ProductModel>> getAllOnSaleProductsFromIdUser(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getAllProductFromUserId/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data =  response.data;
        List<ProductModel> productList = data.map((product) => ProductModel.fromJson(product)).toList();
        return productList;

      }else{
        throw 'Error al obtener la lista de productos: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<ProductModel> getProductById(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getProductById/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        return ProductModel.fromJson(response.data);

      }else{
        throw 'Error al obtener el producto por su id: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
    
  }

  Future<ProductModel?> addProduct(ProductModel productModel,int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.post(
        '${BaseUrlRequest.publicBaseUrl}/saveProduct/$id',
        data: productModel,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':'application/json'
            
          }
        )
      );
      if(response.statusCode == 200){
        return ProductModel.fromJson(response.data);
      }else{
        return null;
      }
    } on DioException{
      return null;
    }
  }

  Future<ProductModel?> updateProduct(ProductModel productModel) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.put(
        '${BaseUrlRequest.publicBaseUrl}/updateProduct',
        data: productModel,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':'application/json'  
          }
        )
      );
      if(response.statusCode == 200){
        return ProductModel.fromJson(response.data);
      }else{
        return null;
      }
    } on DioException{
        return null;
    }
  }

  Future<void> deleteProductById(int productId) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      await _dio.delete(
        '${BaseUrlRequest.publicBaseUrl}/deleteProduct/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':'application/json'
            
          }
        )
      );
    } on DioException {
      rethrow;
    }
  }
}