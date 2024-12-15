import 'package:flutter/material.dart';
import 'package:prime_store/model/data/wallet_model.dart';
import 'package:prime_store/services/wallet_service.dart';

//Clase que maneja el contexto global del monedero del usuario
class WalletProvider with ChangeNotifier {
  final WalletService walletService = WalletService(); //Servicio del monedero
  late WalletModel _walletModel; //Entidad o modelo que representa el monedero
  bool _isLoading = false; //buleano que representa la carga

  //Método que obtiene los datos del monedero deñl usuario de la BBDD
  Future<void> retrieveWallet(int id) async {
    _isLoading = true;
    notifyListeners(); //notifica a los oyentes

    _walletModel = await walletService.getWalletByUserId(id); //obtiene el monedero del usuario desde la BBDD
    _isLoading = false;
    notifyListeners(); //notifica a los oyentes
  }

  //Método que actualiza el saldo del monedero
  Future<void> updateAmountByWalletId(double amount, int walletId) async {
    await walletService.updateWalletAmount(amount, walletId); //actualiza la información en la BBDD
    notifyListeners(); //notifica a los oyentes
  }

  //Getters y Setters
  set setWalletAmount(double quantity) {
    if (_walletModel.amount >= quantity) {
      _walletModel.setWalletAmount(getWalletModel.amount + quantity);
      notifyListeners();
    }
  }
  bool get isLoading => _isLoading;
  WalletModel get getWalletModel => _walletModel;
}
