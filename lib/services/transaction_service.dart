import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class TransactionService {
  final Dio _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<List<TransactionModel>> getAllTransactionsFromUserId(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getAllTransactionsFromIdUser/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data =  response.data;
        List<TransactionModel> transactionList = data.map((product) => TransactionModel.fromJson(product)).toList();
        return transactionList;

      }else{
        throw 'Error al obtener la lista de productos: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getAllTransactions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data =  response.data;
        List<TransactionModel> transactionList = data.map((product) => TransactionModel.fromJson(product)).toList();
        return transactionList;

      }else{
        throw 'Error al obtener la lista de productos: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<TransactionModel?> getTransactionByProductId(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getTransactionByProductId/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        if (response.data == null || response.data == "") {
          return null;
        }else{
          return TransactionModel.fromJson(response.data);
        }
      }else{
        throw 'Error al obtener la lista de productos: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }

  Future<TransactionModel> addTransaction(TransactionModel transactionModel) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      final transactionModelJson = transactionModel.toJson();
      Response response = await _dio.post(
        data: transactionModelJson,
        '${BaseUrlRequest.publicBaseUrl}/saveTransaction',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':'application/json'
          }
        )
      );
      if(response.statusCode == 200){
        return TransactionModel.fromJson(response.data);
      }else{
        throw 'Error al añadir transacción: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
    
  }

  Future<TransactionModel> updateTransaction(TransactionModel transactionModel) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      final transactionModelJson = transactionModel.toJson();
      Response response = await _dio.put(
        data: transactionModelJson,
        '${BaseUrlRequest.publicBaseUrl}/updateTransaction',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':'application/json'
          }
        )
      );
      if(response.statusCode == 200){
        return TransactionModel.fromJson(response.data);
      }else{
        throw 'Error al añadir transacción: ${response.statusCode}';
      }
    }on DioException{
      rethrow;
    }
  }
}