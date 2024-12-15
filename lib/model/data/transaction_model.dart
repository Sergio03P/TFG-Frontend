// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'package:prime_store/model/data/fee_model.dart';
import 'package:prime_store/model/data/review_model.dart';
import 'package:prime_store/util/transaction_conversor.dart';

TransactionModel transactionModelFromJson(String str) => TransactionModel.fromJson(json.decode(str));
String transactionModelToJson(TransactionModel data) => json.encode(data.toJson());

//Clase que representa las transacciones de compra y venta dentro de la app
class TransactionModel {
  int id;
  String date; //fecha de inicio de la transacción
  double totalPrice; //precio total de la transacción
  TransactionState transactionState; //estado de la transacción
  PayMethod payMethod; //método de pago
  DeliveryMethod deliveryMethod; //método de envío
  int sellerId; //identificador del vendedor
  int buyerId; //identificador del comprador
  int productId; //identificador del producto a vender
  ReviewModel? reviewModel; //reseña del comprador al vendedor solo si se ha recibido el producto
  List<FeeModel> fees; //tasas asociadas a la transacción

  //Constructor con parámetros 
  TransactionModel({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.transactionState,
    required this.payMethod,
    required this.deliveryMethod,
    required this.sellerId,
    required this.buyerId,
    required this.productId,
    required this.reviewModel,
    required this.fees
  });

  //Constructor por defecto
  TransactionModel.defaultConstructor():
    id = 0,
    date = "",
    totalPrice = 0,
    transactionState = TransactionState.PENDING,
    payMethod = PayMethod.WALLET,
    deliveryMethod = DeliveryMethod.PERSON,
    sellerId = -1,
    buyerId = -1,
    productId = -1,
    reviewModel = null,
    fees = [];

  //Obtiene los datos del modelo json
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json["id"],
    date: json["date"],
    totalPrice: json["total_price"]?.toDouble(),
    transactionState: transactionStateFromBBDDConversion(json["transactionState"]),
    payMethod: payMethodFromBBDDConversion(json["payMethod"]),
    deliveryMethod: deliveryMethodFromBBDDConversion(json["deliveryMethod"]),
    sellerId: json["sellerId"],
    buyerId: json["buyerId"],
    productId: json["productId"],
    reviewModel: json["review"] != null ? ReviewModel.fromJson(json["review"]) : null, //?
    fees: (json["fees"] as List<dynamic>? ?? []).map((feeJson) => FeeModel.fromJson(feeJson)).toList()
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "total_price": totalPrice,
    "transactionState": transactionState.name,
    "payMethod": payMethod.name,
    "deliveryMethod": deliveryMethod.name,
    "sellerId": sellerId,
    "buyerId": buyerId,
    "productId": productId,
    "review": reviewModel,
    "fees": fees
  };

  //Getters y Setters
  get getFees => fees;
  get getTotalPrice => totalPrice;
  get getReviewModel => reviewModel;
  set setFees(List<FeeModel> fee) => fees = fee;
  set setReviewModel(ReviewModel reviewModel) => this.reviewModel = reviewModel;
  set setTotalPrice(double amount) => totalPrice = amount;

  @override
  String toString() {
    return '''TransactionModel(id: $id, date: $date, totalPrice: $totalPrice, transactionState: $transactionState,
    payMethod: $payMethod, deliveryMethod: $deliveryMethod, sellerId: $sellerId, buyerId: $buyerId, productId: $productId)
    fees: ${fees.toString()}, reviewModel: ${reviewModel.toString()}''';
  }
}
 enum TransactionState{COMPLETED, PENDING, CANCELED}
 enum PayMethod{CARD, PAYPAL, CASH, WALLET}
 enum DeliveryMethod{DELIVERY, PERSON}