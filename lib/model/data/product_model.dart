// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'package:prime_store/util/category_product_conversor.dart';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));
String productModelToJson(ProductModel data) => json.encode(data.toJson());

//Clase que se representa los productos de la aplicación
class ProductModel {
  int id;
  String name; //nombre del producto
  String description; //descripción del producto
  double price; //precio del producto
  String? date; //fecha de subida del producto a la app
  List<String?> images; //imágenes del producto
  String category; //categoría a la que pertenece el producto
  int ownerUserId; //id del usuario al que pertenece el producto

    //Constructor con parámetros
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.date,
    required this.images,
    required this.category,
    required this.ownerUserId
  });

  //Constructor por defecto
  ProductModel.defaultConstructor(): 
    id = 0,
    name = '',
    description = '',
    price = 0.0,
    date = '',
    images = [],
    category = ProductCategoryEnum.OTROS.name,
    ownerUserId = 0;

  //Método para clonar un producto pero que no apunte al mismo espacio en memoria
  ProductModel clone() {
    return ProductModel(
      id: id,
      name: name,
      description:description,
      price: price,
      date:date,
      category: category,
      images: List<String?>.from(images),
      ownerUserId: ownerUserId,
    );
  }
  //Obtiene los datos del modelo json
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"]?.toDouble(),
    date: json["date"],
    images: List<String?>.from(json["images"].map((x) => x)),
    category: categoryConversor(toProductEnumType(json["category"])),
    ownerUserId: json["ownerUserId"]
  );

  //Convierte el modelo de datos a json
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "date": date,
    "images": List<String?>.from(images.map((x) => x)),
    "category": category,
    "ownerUserId" : ownerUserId 
  };

  //Setters
  set setId(int id) => this.id = id;
  set setName(String name) => this.name = name;
  set setDescription(String description) => this.description = description;
  set setPrice(double price) => this.price = price;
  set setDate(String? date) => this.date = date;
  set setImages(List<String?> images) => this.images = images;
  set setCategory(String category) => this.category = category;
  set setOwnerUserId(int ownerUserId) => this.ownerUserId = ownerUserId;

  //toString
  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, description: $description, price: $price, date: $date, images: $images, category: $category, ownerUserId: $ownerUserId}';
  }
}

//Enumerado de las categorías a las que puede pertenecer el producto
enum ProductCategoryEnum{
  COCHES, MOTOS, MODA_Y_ACCESORIOS, TECNOLOGIA, DEPORTE_Y_OCIO, BICICLETAS, HOGAR, ELECTRODOMESTICO,
  CINE, LIBROS, MUSICA, COLECCIONISMO, CONSTRUCCION, OTROS 
}
