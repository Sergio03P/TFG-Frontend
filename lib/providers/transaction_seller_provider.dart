import 'package:flutter/material.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/services/transaction_service.dart';

//Clase que maneja el contexto global de las transacciones de venta del usuario
class TransactionSellerProvider with ChangeNotifier{
  final TransactionService transactionService = TransactionService(); //Servicio de las transacciones
  List<TransactionModel> sellerTransactionsList = []; //Lista de las transacciones de venta

  //Método para obtener la lista de transacciones de venta del usuario en la app
  Future<List<TransactionModel>> retrieveSellerTransactionsList(int id) async{
    sellerTransactionsList.clear(); //limpia la lista
    //Obtiene todas la transacciones
    List<TransactionModel> transactionList = await transactionService.getAllTransactionsFromUserId(id);
    //Filtra la lista de transacciones donde el usuario es el vendedor
    sellerTransactionsList = transactionList.where((transaction) => transaction.sellerId == id).toList();
    notifyListeners(); //notifica a los oyentes
    return sellerTransactionsList;
  }

  //Getters y Setters
  List<TransactionModel> get getSellerTransactionsList => sellerTransactionsList;
  set setSellerTransactionsList(List<TransactionModel> list){
    sellerTransactionsList = list;
    notifyListeners();
  }
}