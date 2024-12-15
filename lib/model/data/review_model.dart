import 'dart:convert';

ReviewModel reviewModelFromJson(String str) => ReviewModel.fromJson(json.decode(str));
String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

//Clase que representa las reseñas de los usuarios en la aplicación
class ReviewModel {
  int id;
  double rate; //puntuación del usuario del 0-5
  String comment; //breve comentario hacia al vendedor

  //Constructor con parámetros
  ReviewModel({
    required this.id,
    required this.rate,
    required this.comment,
  });

  //Constructor por defecto
  ReviewModel.defaultConstructor():
    id = 0,
    rate = 0.0,
    comment = '';

  //Obtiene los datos del modelo json
  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json["id"],
    rate: json["rate"]?.toDouble(),
    comment: json["comment"],
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "rate": rate,
    "comment": comment
  };

  //Getters y Setters
  get getRate => rate;
  get getComment => comment;
  set setRate(double rateParam) => rate = rateParam;
  set setComment(String commentParam) => comment = commentParam;

  @override
  String toString() {
    return "ReviewModel(id: $id, rate: $rate, comment:$comment)";
  }
}