import 'package:flutter/material.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/services/transaction_service.dart';

//Maneja la transacciones globales de la app
class TransactionGlobalProvider with ChangeNotifier{
  final TransactionService transactionService = TransactionService();
  List<TransactionModel> transactionGlobalList = [];

  //Método que obtiene todas las transacciones de todos los usuarios de la app
  Future<List<TransactionModel>> retrieveGlobalTransactionsList() async{
    transactionGlobalList.clear(); //limpia la lista
    transactionGlobalList = await transactionService.getAllTransactions(); //obtiene todas las transacciones
    notifyListeners(); //notifica a los oyentes
    return transactionGlobalList;
  }

  //Método que añade una transacción
  Future<TransactionModel> addTransaction(TransactionModel transactionModel) async{
    //Añade la transacción a la BBDD
    TransactionModel savedTransaction = await transactionService.addTransaction(transactionModel);
    transactionGlobalList.add(savedTransaction); //Añade la transacción a la lista
    notifyListeners(); //notifica a los oyentes
    return savedTransaction;
  }

  //Getters y Setters
  get getTransactionGlobalList => transactionGlobalList;
  set setTransactionGlobalList(List<TransactionModel> list){
    transactionGlobalList = list;
    notifyListeners();
  } 
}