import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
String userModelToJson(UserModel data) => json.encode(data.toJson());

//Clase que representa a los usuarios dentro de la app
class UserModel {
  int id;
  String username; //nombre de usuario
  String email; //correo electrónico
  String name; //nombre real de la persona
  String firstname; //primer apellido
  String lastname; //segundo apellido
  int postalCode; //código postal
  String role; //rol del usuario dentro del ecosistema
  String registerDate; //fecha de registro del usuario
  String? profilePicture; //foto de perfil del usuario

  //Constructor con parámetros
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.firstname,
    required this.lastname,
    required this.postalCode,
    required this.role,
    required this.registerDate,
    required this.profilePicture
  });

  //Obtiene los datos del modelo json
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    name: json["name"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    postalCode: json["postalCode"],
    role: json["role"],
    registerDate: json["registerDate"],
    profilePicture: json["profilePicture"]
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "name": name,
    "firstname": firstname,
    "lastname": lastname,
    "postalCode": postalCode,
    "role": role,
    "registerData": registerDate,
    "profilePicture": profilePicture
  };
}