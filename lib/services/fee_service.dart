import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/fee_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class FeeService with ChangeNotifier{
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<List<FeeModel>> getFees() async {
    try {
      String? token = await _secureStorage.read(key: "jwtToken");
      if (token == null) throw 'Token no encontrado';

      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getFeesList',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((fee) => FeeModel.fromJson(fee)).toList();
      } else {
        throw 'Error al obtener el fee pot id: ${response.statusCode}';
      }
    } on DioException{
      rethrow;
    }
  }

  Future<FeeModel> getFeeById(int id) async {
    try {
      String? token = await _secureStorage.read(key: "jwtToken");
      if (token == null) throw 'Token no encontrado';

      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getFeeById/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return FeeModel.fromJson(response.data);
      } else {
        throw 'Error al obtener el fee pot id: ${response.statusCode}';
      }
    } on DioException{
      rethrow;
    }
  }

  Future<FeeModel> getFeeByName(String id) async {
    try {
      String? token = await _secureStorage.read(key: "jwtToken");
      if (token == null) throw 'Token no encontrado';

      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getFeeByName/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return FeeModel.fromJson(response.data);
      } else {
        throw 'Error al obtener la lista de fees: ${response.statusCode}';
      }
    } on DioException{
      rethrow;
    }
  }
}