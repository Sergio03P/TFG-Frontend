import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prime_store/model/data/transaction_fee_model.dart';
import 'package:prime_store/services/common/base_url_request.dart';

class TransactionFeeService {
  final _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  Future<List<TransactionFeeModel>>getTransactionFeeModelByTransactionId(int id) async{
    try{
      final String? token = await _secureStorage.read(key: 'jwtToken');
      Response response = await _dio.get(
        '${BaseUrlRequest.publicBaseUrl}/getTransactionFeeModelByTransactionId/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          }
        )
      );
      if(response.statusCode == 200){
        List<dynamic> data = response.data;
        return data.map((transactionFeeModel) => TransactionFeeModel.fromJson(transactionFeeModel)).toList();
      }else{
        throw ('Error al la lista de transactionFee pot t Id\nerrorCode:${response.statusCode}');
      }
    } on DioException{
      rethrow;
    }
    
  }
}