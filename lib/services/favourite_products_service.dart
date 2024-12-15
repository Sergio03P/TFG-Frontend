import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class FavoutiteProductsService{
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<List<ProductModel>> getAllFavouriteProducts(int userId) async {
    try {
      String? token = await _secureStorage.read(key: "jwtToken");
      if (token == null) throw 'Token no encontrado';

      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getFavouriteUserProducts/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((product) => ProductModel.fromJson(product)).toList();
      } else {
        throw 'Error al obtener la lista de productos favoritos: ${response.statusCode}';
      }
    } on DioException{
      rethrow;
    }
  }

  Future<ProductModel?> addFavouriteProduct(int userId, int productId) async {
    try {
      String? token = await _secureStorage.read(key: "jwtToken");
      if (token == null) throw 'Token no encontrado';

      Response response = await _dio.post(
        '${BaseUrlRequest.publicBaseUrl}/addFavouriteProduct/$userId,$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data.toString().isNotEmpty
            ? ProductModel.fromJson(response.data)
            : null;
      } else {
        throw 'Error al añadir el producto a favoritos: ${response.statusCode}';
      }
    } on DioException{
      rethrow;
    }
  }

  Future<bool> removeFavouriteProduct(int userId, int productId) async {
    try {
      String? token = await _secureStorage.read(key: "jwtToken");
      if (token == null) throw 'Token no encontrado';

      Response response = await _dio.delete(
        '${BaseUrlRequest.publicBaseUrl}/removeFavouriteProduct/$userId,$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data.toString().isNotEmpty;
      } else {
        throw 'Error al borrar el producto de favoritos: ${response.statusCode}';
      }
    } on DioException{
      rethrow;
    }
  }
}

