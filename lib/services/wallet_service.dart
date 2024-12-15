import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/wallet_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class WalletService {
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<WalletModel>getWalletByUserId(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getWalletByUserId/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        return WalletModel.fromJson(response.data);
      }else{
        throw ('Error al obtener el monedero Id\nerrorCode:${response.statusCode}');
      }
    } on DioException{
      rethrow;
    }
    
  }

  Future<WalletModel>saveWallet(WalletModel walletModel) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.post(
        '${BaseUrlRequest.publicBaseUrl}/saveWallet',
        data: walletModel,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        return WalletModel.fromJson(response.data);
      }else{
        throw Exception('Error al obtener al usuario por su email\nerrorCode:${response.statusCode}');
      }
    }on DioException{
      rethrow;
    }
    
  }

  Future<bool>updateWalletAmount(double amount, int walletId) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.put(
        '${BaseUrlRequest.publicBaseUrl}/updateWalletAmount/$amount,$walletId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        return true;
      }else{
        return false;
      }
    }on DioException{
      rethrow;
    }
  }
}