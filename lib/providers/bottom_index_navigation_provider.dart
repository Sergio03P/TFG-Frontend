import 'package:flutter/material.dart';

//Clase que maneja el contexto global del índice de la barra inferior de la página principal
class BottomIndexNavigationProvider with ChangeNotifier{
  int _index = 0;

  //Setter del índice
  set setIndex(int index) {
    if(index >= 0 && index < 5){
      _index = index;
      notifyListeners();
    }    
  }
  
  //Getter 
  get getIndex => _index;
}