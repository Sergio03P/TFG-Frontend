import 'package:flutter/material.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/services/user_service.dart';

//Clase que maneja el contexto global del usuario dentro de la app
class UserProvider with ChangeNotifier{
  final userService = UserService(); //Se encarga de conectarse con el servicio y hacer peticiones
  late UserModel? _userAuthenticated; //representa al usuario autenticado dentro de la app

  //Buscamos al usuario dentro de la BBDD y lo insertamos en la variable _userAuthenticated
  Future<void> retrieveAuthenticatedUser(String username) async{
    _userAuthenticated = await userService.getUserByUsername(username);
    //notificamos a todas las clases que esten escuchando _userAuthenticated para que se redibujen
    notifyListeners();
  }

  //Este método actualiza los datos del usuario
  Future<bool> updateAuthenticatedUser(UserModel userModel) async{
    try{
      _userAuthenticated = await userService.updateUser(userModel);
      notifyListeners();
      return true;
    }catch (e){
      return false;
    } 
  }

  //Método que cierra la sesión e iguala a null al usuario autenticado
  void logOut(){
    _userAuthenticated = null;
    notifyListeners();
  }

  //Getters y Setters
  UserModel? get getUserAuthenticated => _userAuthenticated; //devuelve el usuario autenticado

  set setuserAuthenticated(UserModel? user){
    _userAuthenticated = user;
    notifyListeners();
  }
  int? get getUserAuthenticatedId => _userAuthenticated?.id; //devuelve el id del usuario autenticado
}