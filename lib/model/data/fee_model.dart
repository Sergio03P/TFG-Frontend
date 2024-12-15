import 'dart:convert';

FeeModel feeModelFromJson(String str) => FeeModel.fromJson(json.decode(str));
String feeModelToJson(FeeModel data) => json.encode(data.toJson());

//Clase que representa el modelo de dato de las tasas en las transacciones
class FeeModel {
  final int id;
  final String name; //nombre
  final String feeType; //tipo de tasa
  final double amount; //cantidad de la tasa

  //Constructor
  FeeModel({
    required this.id,
    required this.name,
    required this.feeType,
    required this.amount,
  });

  //Obtiene los datos del modelo json
  factory FeeModel.fromJson(Map<String, dynamic> json) => FeeModel(
    id: json["id"],
    name: json["name"],
    feeType: json["feeType"],
    amount: json["amount"]?.toDouble(),
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "feeType": feeType,
    "amount": amount,
  };

  @override
  String toString() {
    return 'FeeModel(id: $id, name: "$name", feeType: "$feeType", amount: $amount)';
  }
}
