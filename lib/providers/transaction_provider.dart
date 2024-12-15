import 'package:flutter/material.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/services/transaction_service.dart';

//Clase idéntica a "TransactionGlobalProvider"
class TransactionProvider with ChangeNotifier{
  final TransactionService transactionService = TransactionService();
  List<TransactionModel> transactionList = [];

  Future<List<TransactionModel>> retrieveTransactionsList(int id) async{
    transactionList.clear();
    transactionList = await transactionService.getAllTransactionsFromUserId(id);
    notifyListeners();
    return transactionList;
  }

  Future<List<TransactionModel>> getAllTransactions() async{
    return await transactionService.getAllTransactions();
  }

  Future<TransactionModel?> getTransactionByProductId(int id) async{
    return await transactionService.getTransactionByProductId(id);
  }

  List<TransactionModel> get getTransactionList => transactionList;
  set setTransactionList(List<TransactionModel> list){
    transactionList = list;
    notifyListeners();
  }

  Future<TransactionModel> addTransaction(TransactionModel transactionModel) async{
    TransactionModel savedTransaction = await transactionService.addTransaction(transactionModel);
    notifyListeners();
    return savedTransaction;
  }
}