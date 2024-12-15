import 'dart:convert';

TransactionFeeModel transactionFeeModelFromJson(String str) => TransactionFeeModel.fromJson(json.decode(str));
String transactionFeeModelToJson(TransactionFeeModel data) => json.encode(data.toJson());

//Clase que representa la relación muchos a muchos entre la entidad de transacciones y tasas
class TransactionFeeModel {
  final int id;
  final int transactionId; //identificador de la transacción a la que pertenece
  final int feeId; //identificador de la tasa a la que pertenece

  //Constructor con parámetros
  TransactionFeeModel({
    required this.id,
    required this.transactionId,
    required this.feeId,
  });
  
  //Obtiene los datos del modelo json
  factory TransactionFeeModel.fromJson(Map<String, dynamic> json) => TransactionFeeModel(
    id: json["id"],
    transactionId: json["transactionId"],
    feeId: json["feeId"],
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "transactionId": transactionId,
    "feeId": feeId,
  };
}
