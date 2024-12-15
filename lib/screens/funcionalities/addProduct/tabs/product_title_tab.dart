import 'package:flutter/material.dart';
import 'package:prime_store/widgets/formInputs/custom_input_field.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:provider/provider.dart';

//Clase que funciona como tab y sirve para darle un nombre inicial al producto
// ignore: must_be_immutable
class ProductTitleTab extends StatefulWidget {
  final TabController tabController; //controlador del tabBarView
  ProductModel newProductModel; //producto que se va a subir en la app

  //Constructor
  ProductTitleTab({
    super.key,
    required this.tabController,
    required this.newProductModel
  });

  @override
  State<ProductTitleTab> createState() => _ProductTitleTabState();
}

class _ProductTitleTabState extends State<ProductTitleTab> {
  late TextEditingController _titleTextFormField;

  @override
  void initState() {//se inicializan los valores
    super.initState();
    _titleTextFormField = TextEditingController();
  }

  @override
  void dispose() {//se liberan los recursos
    _titleTextFormField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView( //permite el scroll vertical
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: (){ //vuelve a la pantalla principal
                  Provider.of<BottomIndexNavigationProvider>(context,listen: false).setIndex = 0;
                  Navigator.pop(context);
                }, 
                icon: const Icon(Icons.arrow_back)
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,100,0,20),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: Image.asset(
                  'images/add_product_funcionality_image.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Text(
              '¿Qué te interesa vender?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Un buen título describe tu producto de forma clara y resalta sus detalles más importantes.',
            ),
            const SizedBox(height: 15),
            CustomInputField(
              controller: _titleTextFormField,
              hintText: "Título", 
              keyboardType: TextInputType.text, 
              validator: null
            ),
            const SizedBox(height: 1),
            Text(
              'Ejemplo: Cámara Digital Canon EOS 2000D Seminueva',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500]
              ),
            ),
            const SizedBox(height: 75), //todo altura del boton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  widget.newProductModel.setName = _titleTextFormField.value.text;
                  widget.tabController.animateTo(1); //pasa al tab siguiente
                }, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}