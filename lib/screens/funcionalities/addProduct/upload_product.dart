import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/screens/funcionalities/addProduct/tabs/product_category_selector_tab.dart';
import 'package:prime_store/screens/funcionalities/addProduct/tabs/product_details_tab.dart';
import 'package:prime_store/screens/funcionalities/addProduct/tabs/product_title_tab.dart';

//Clase que contiene los diferentes 'tabs' para subir un producto a la aplicación
class UploadProduct extends StatefulWidget {
  const UploadProduct({super.key});

  @override
  State<UploadProduct> createState() => _UploadProductState();
}

class _UploadProductState extends State<UploadProduct> with SingleTickerProviderStateMixin {
  late final TabController tabController; //controlador del tabBar
  final int _index = 0; //índice del tab para manejar el tab que va a mostrarse
  late final ProductModel newProductModel; //producto que vamos a subir

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 3, //número de tabs
      vsync: this, //referencia a la clase que maneja el estado del TabBar
      initialIndex: _index, //índice
    );
    /**Se crea un nuevo espacio en memoria que va a almacenar los datos del producto que se
      va a ir recogiendo en los diferentes tabs**/
    newProductModel = ProductModel.defaultConstructor();
  }

  @override
  void dispose() { //liberamos los recursos
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea( //Crea un margen en los bordes de la pantalla
        child: SingleChildScrollView( //permite el scroll
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9, // todo 90% para el tab y el otro 10% para el selector
                child: TabBarView(
                  controller: tabController, //controlador del tab
                  physics: const NeverScrollableScrollPhysics(), //No permite la navegación al deslizar
                  children: [
                    ProductTitleTab(tabController: tabController, newProductModel: newProductModel),
                    ProductCategorySelectorTab(tabController: tabController, newProductModel: newProductModel),
                    ProductDetailsTab(tabController: tabController, newProductModel: newProductModel,)
                  ],
                ),
              ),
              // Selector de pestañas en la parte inferior sin padding
              Positioned(
                left: MediaQuery.of(context).size.width/2.4, //posición del selector
                bottom: 0,
                child: TabPageSelector(
                  controller: tabController, //controlador, el mismo que el tabBarView
                  color: Colors.grey,
                  selectedColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
