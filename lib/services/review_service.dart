import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/review_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class ReviewService {
  final Dio _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<List<ReviewModel>> getAllReviews() async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getAllReviews',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data =  response.data;
        List<ReviewModel> reviewList = data.map((product) => ReviewModel.fromJson(product)).toList();
        return reviewList;

      }else{
        throw 'Error al obtener todas las reviews: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<List<ReviewModel>> findReviewsByTransactionId(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/findReviewsByTransactionId/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data =  response.data;
        List<ReviewModel> reviewList = data.map((product) => ReviewModel.fromJson(product)).toList();
        return reviewList;

      }else{
        throw 'Error al obtener todas las reviews: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<ReviewModel> saveReview(ReviewModel reviewModel) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.post(
        '${BaseUrlRequest.publicBaseUrl}/saveReview',
        data: reviewModel,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        return ReviewModel.fromJson(response.data);
      }else{
        throw 'Error al obtener todas las reviews: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }
}