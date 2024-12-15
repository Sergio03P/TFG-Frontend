import 'dart:convert';

WalletModel walletModelFromJson(String str) => WalletModel.fromJson(json.decode(str));
String walletModelToJson(WalletModel data) => json.encode(data.toJson());

//Clase que representa el monedero de la aplicación y que se asocia a un usuario dentro de la app
class WalletModel {
  final int id;
  double amount; //cantidad del monedero
  final int userModelId; //identificador del usuario al que pertenece el monedero

  //Constructor con parámetros
  WalletModel({
    required this.id,
    required this.amount,
    required this.userModelId,
  });

  //Obtiene los datos del modelo json
  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    id: json["id"],
    amount: json["amount"],
    userModelId: json["userModelId"],
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "amount": amount,
    "userModelId": userModelId,
  };

  //Método que modifica el salario del monedero
  void setWalletAmount(double amount){
    if(this.amount + (amount) >=0){
      this.amount = this.amount + (amount);
    }
  }
}
