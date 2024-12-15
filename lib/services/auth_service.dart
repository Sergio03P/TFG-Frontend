import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class AuthService {
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<int>login(String username, String password) async{
    try{
      Response response = await _dio.post(
        '${BaseUrlRequest.authBaseUrl}/login',
        data: {
          'username':username,
          'password':password
        },
        options: Options(
          headers: {
            'Content-Type':'application/json'
          }
        )
      );
      
      if(response.statusCode == 200){
        final token = response.data["token"]; //*Se obtiene el token JWT en la respuesta
        final chatToken = response.data["chatToken"];
        //guarda el token en almacenamiento seguro
        await _secureStorage.write(key: 'jwtToken', value: token);
        await _secureStorage.write(key: "jwtChatToken", value: chatToken);
        return response.statusCode!;
      }else{
        throw Exception("Error de autenticación: ${response.statusCode}");
      }
    } on DioException {
      rethrow ;
    }
  }

  Future<bool> register(
    String username,
    String email,
    String password,
    String name,
    String firstname,
    String lastname,
    int postalCode
  ) async{
    try{
      Response response = await _dio.post(
        '${BaseUrlRequest.authBaseUrl}/register',
        data: {
          "username": username,
          "email": email,
          "password":password,
          "name": name,
          "firstname": firstname,
          "lastname": lastname,
          "postalCode": postalCode,
          "profilePicture": null
        },
        options: Options(
          headers: {
            'Content-Type':'application/json'
          }
        )
      );
      if(response.statusCode == 200){
        final token = response.data["token"];
        await _secureStorage.write(key: 'jwtToken', value: token);
        return true;
      }else{
        return false;
      }
    } on DioException{
      rethrow;
    }
  }
}