import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class UserService {
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<UserModel>getUserById(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getUser/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        UserModel userModel = UserModel.fromJson(response.data);
          return userModel;
      }else{
        throw ('Error al obtener al usuario por su Id\nerrorCode:${response.statusCode}');
      }
    } on DioException{
      rethrow;
    }
    
  }

  Future<UserModel?>getUserByEmail(String email) async{
    final String? token = await _secureStorage.read(key: 'jwtToken');
    Response response = await _dio.get(
      '${BaseUrlRequest.publicBaseUrl}/getUserByEmail/$email',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      )
    );
    if(response.statusCode == 200){
      if(response.data != null){
        UserModel userModel = UserModel.fromJson(response.data);
        return userModel;
      }else{
        return null;
      }
      
    }else{
      throw Exception('Error al obtener al usuario por su email\nerrorCode:${response.statusCode}');
    }
  }

  Future<UserModel?>getUserByUsername(String username) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getUserByUsername/$username',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        if(response.data != null){
          UserModel userModel = UserModel.fromJson(response.data);
          return userModel;
        }else{
          return null;
        }
      }else{
        throw ('Error al obtener al usuario por su username\nerrorCode:${response.statusCode}');
      }
    } on DioException{
      rethrow;
    }
  }

  Future<UserModel>updateUser(UserModel userModel) async{
    final String? token = await _secureStorage.read(key: 'jwtToken');
    Response response = await _dio.put(
      '${BaseUrlRequest.publicBaseUrl}/updateUser',
      data: userModelToJson(userModel),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      )
    );
    if(response.statusCode == 200){
      UserModel userModel = UserModel.fromJson(response.data);
      return userModel;
    }else{
      throw Exception('Error al obtener al actualizar lo datos del usuario\nerrorCode:${response.statusCode}');
    }
  }
}