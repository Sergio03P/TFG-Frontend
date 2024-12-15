import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/util/category_product_conversor.dart';

//Clase que funciona como un tab y sirve para elegir la categoría del producto
// ignore: must_be_immutable
class ProductCategorySelectorTab extends StatefulWidget {
  final TabController tabController;
  ProductModel newProductModel;

  ProductCategorySelectorTab({
    super.key,
    required this.tabController, //controlador del tabBarView para controlar la navegación
    required this.newProductModel //producto que vamos a subir a la app
  });

  @override
  State<ProductCategorySelectorTab> createState() => _ProductCategorySelectorTabState();
}

class _ProductCategorySelectorTabState extends State<ProductCategorySelectorTab> {
  //Lista de iconos según la categoría
  List<IconData> iconsList = [
    Icons.directions_car_rounded,
    Icons.directions_bike_outlined,
    Icons.checkroom_outlined,
    Icons.computer_outlined,
    Icons.sports_basketball,
    Icons.pedal_bike_outlined,
    Icons.home,
    Icons.kitchen,
    Icons.movie,
    Icons.menu_book_sharp,
    Icons.my_library_music_rounded,
    Icons.store,
    Icons.build,
    Icons.help_outline_sharp
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed:(){
                widget.tabController.animateTo(0);
              }, 
              icon: const Icon(Icons.arrow_back)
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9,vertical: 6),
            child: Center(
              // ignore: prefer_adjacent_string_concatenation
              child:Text("Selecciona la categoría que mejor se adapte al tipo de" +
                "producto que quieres vender, así será más fácil que otros usuarios puedan encontarlo",
                style: GoogleFonts.abel(fontSize: 16, fontWeight: FontWeight.bold),
              )
            ),
          ),
          Image.asset("images/cartoon_pointing_down.png", height: 150),
          Expanded(
            child: ListView.builder( //list view con todas la categorías posibles para asignar al producto
              itemCount: ProductCategoryEnum.values.length,
              itemBuilder: (context, index){
                return Container( //contenedor que envuelve cada opción
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  padding: const EdgeInsets.all(0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.teal[300],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal)
                  ),
                  child:               
                    ListTile(
                      onTap: (){
                        widget.newProductModel.setCategory = ProductCategoryEnum.values[index].name;    
                        widget.tabController.animateTo(2);
                      },
                      dense: true,  //toma el menor espacio posible
                      leading: Icon(iconsList[index], color: Colors.white),
                      title: Text(
                        //Devuelve una cadena de texto legible del nombre de la categoría
                        categoryConversor(ProductCategoryEnum.values[index]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19
                        ),
                      )
                    ),
                  );
              },
            ),
          ),
          const SizedBox(height: 8)
        ],
      ),
    );
  }
}