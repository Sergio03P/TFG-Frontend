import 'package:flutter/material.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/services/transaction_service.dart';

//Clase que maneja el contexto global de las transacciones de compra del usuario
class TransactionBuyerProvider with ChangeNotifier{
  final TransactionService transactionService = TransactionService(); //Servicio de las transacciones
  List<TransactionModel> buyerTransactionsList = []; //Lista de las transacciones de compra

  //Método para obtener las listas de transacciones de compra de la BBDD
  Future<List<TransactionModel>> retrieveBuyerTransactionsList(int id) async{
    buyerTransactionsList.clear(); //limpia la lista
    //Obtiene la lista de la BBDD
    List<TransactionModel> transactionList = await transactionService.getAllTransactionsFromUserId(id);
    //Flitra las transacciones donde el usuario es el comprador
    buyerTransactionsList = transactionList.where((transaction) => transaction.buyerId == id).toList();
    notifyListeners(); //notifca a los oyentes
    return buyerTransactionsList;
  }

  //Actualiza el estado de la transacción localmente
  updateTransactionState(int id, TransactionState state){
    // Buscar la transacción en la lista actual
    int index = buyerTransactionsList.indexWhere((transaction) => transaction.id == id);
    
    if (index != -1) {
      // Si la actualización fue exitosa, modificar el estado localmente
      buyerTransactionsList[index].transactionState = state;
      notifyListeners();
      
    }
  }

  //Getters y Setters
  List<TransactionModel> get getBuyerTransactionsList => buyerTransactionsList;
  set setBuyerTransactionsList(List<TransactionModel> list){
    buyerTransactionsList = list;
    notifyListeners();
  }
}