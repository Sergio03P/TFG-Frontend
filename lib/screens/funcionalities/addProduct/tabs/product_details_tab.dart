// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_store/widgets/formInputs/custom_input_field.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/services/cloudinary_service.dart';
import 'package:prime_store/services/product_service.dart';
import 'package:prime_store/styles/widgets_styles.dart';
import 'package:provider/provider.dart';

//Clase que funciona como tab y sirve para añadir los detalles del producto que faltan o editar otros
// ignore: must_be_immutable
class ProductDetailsTab extends StatefulWidget {
  final TabController tabController; //controlador del tabBarView para controlar la navegación entre tabs
  ProductModel newProductModel; //producto que vamos a subir en la app

  //Construcor
  ProductDetailsTab({
    super.key,
    required this.tabController,
    required this.newProductModel
  });

  @override
  State<ProductDetailsTab> createState() => _ProductDetailsTabState();
}

class _ProductDetailsTabState extends State<ProductDetailsTab> {
  final ImagePicker _picker = ImagePicker(); //instancia de la libería que nos permite seleccionar imagenes
  final List<XFile?> _images = List<XFile?>.filled(8, null);// lista de XFile que representa la ruta del archivo seleccionado
  final ProductService productService = ProductService(); //Servicio del producto
  late TextEditingController _nameController; //controlador del campo de texto del nombre del producto
  late TextEditingController _descriptionController; //controlador del campo de texto la descripción del producto
  late TextEditingController _priceController; //controlador del campo de texto del precio del producto
  final _formKey = GlobalKey<FormState>(); //controlador del estado global del formulario
  final CloudinaryService cloudinaryService = CloudinaryService(); //Servicio de Cloudinary

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text:widget.newProductModel.name //se le da un valor inicial al campo de texto del nombre
    );
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  //Muestra un diálogo solicitando al usuario que suba al menos una foto del producto
  Widget buildNeedPictureDialog(){
    return AlertDialog(
      title: Text("Añade una imagen de tu producto",style: GoogleFonts.abel(fontSize: 18, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/animations/camera_v1.json", repeat: true, height: 120),
          const SizedBox(height: 5),
          // ignore: prefer_const_constructors, prefer_adjacent_string_concatenation
          Text("Es muy importante que subas al menos una imagen de tu producto, así será " +
                "más fácil que otras personas se interesen en adquirirlo",
                textAlign: TextAlign.justify,
                //style: GoogleFonts.abel(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])
              )
        ],
      ),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context); //cierra el diálogo al pulsar en 'Cerrar'
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  // Función para abrir la cámara o la galería
  Future<void> _selectImage(int index) async {
    final XFile? image = await showModalBottomSheet<XFile>( //abre un BottomSheet y espera que devuelva un valor
      context: context,
      builder: (context) => _buildBottomSheet(), //función que muestra el bottomSheet
    );
    if (image != null) { //si el bottomSheet devuelve un XFile lo añade a la lista
      setState(() {
        _images[index] = image;
      });
    }
  }

  //Función para borrar la imagen seleccionada
  Future<void> _dropImage(int index) async {
    await showModalBottomSheet<XFile>(
      context: context,
      builder: (context) => _buildRemovePictureBottomSheet(index)//Muestra el BottomSheet
    );
  }

  //Contenido del bottomSheet
  Widget _buildRemovePictureBottomSheet(int index){
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 3),
      child: ListTile(
        leading: const Icon(Icons.delete_outline_outlined),
        title: const Text("Eliminar la foto actual"),
        onTap: (){
          _images[index] = null; //elimina la foto de la lista
          Navigator.pop(context); //cierra el bottomSheet
        },
      ),
    );
  }

  // Modal con opciones para seleccionar imagen o abrir la cámara
  Widget _buildBottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Tomar Foto'),
          onTap: () async {
            //Obtiene la ruta de la imagen a través de una foto hecha con la cámara
            final XFile? image = await _picker.pickImage(source: ImageSource.camera);
            Navigator.pop(context, image); //cierra el modal
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo),
          title: const Text('Elegir de la Galería'),
          onTap: () async {
            //Obtiene la imagen de la galería
            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
            Navigator.pop(context, image); //cierra el modal
          },
        ),
      ],
    );
  }

  // Widget que construye la cuadrícula de imágenes
  Widget _buildImageGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Para evitar que se desplace, ya que hay más elementos abajo
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 columnas
        crossAxisSpacing: 5, //espacio en el eje OY
        mainAxisSpacing: 5, //espacio en el OX
        childAspectRatio: 1, //radio
      ),
      itemCount: _images.length, //posiciones de acuerdo a la lista de imágenes
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode()); //Elimina el foco de texto
            _selectImage(index); //selecciona la imagen en la posición del Grid que se haya pulsado
          },
          onLongPress: (){
            FocusScope.of(context).requestFocus(FocusNode()); //Elimina el foco de texto
            if(_images[index] != null){
              _dropImage(index); //Si la imagen en la posición del Grid es disntinta de nulo se elimina
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[300], 
            ),
            child: _images[index] != null //Si hay imagen seleccionada se muestra si no, se ve un icono
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                      File(_images[index]!.path),
                      fit: BoxFit.cover,
                    ),
                )
                : const Icon(Icons.add_a_photo, color: Colors.grey),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( //permite hacer el scroll vertical en la pantalla
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey, //controlador global del formulario
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      widget.tabController.animateTo(1); // vuelve a la pantalla anterior
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Detalles del producto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              
              // Cuadrícula de imágenes en la parte superior
              _buildImageGrid(),
              const SizedBox(height: 20),
              CustomInputField(
                controller: _nameController, 
                keyboardType: TextInputType.text,
                labelText: "Nombre",
                validator: (value){
                  if(value!.isEmpty){
                    return "El campo nombre es requerido";
                  }else if(value.length < 3){
                    return "El nombre del producto demasiado corto";
                  }
                  return null;
                }
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción del producto',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value!.isEmpty){
                    return "El campo descripción es requerido";
                  }else if(value.length < 10){
                    return "La descripción del producto demasiado corto (min 10 letras)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomInputField(
                controller: _priceController,
                labelText: "Precio",
                keyboardType: TextInputType.number, 
                validator:(value){
                  if(value!.isEmpty){
                    return "Necesitas añadir un precio al producto";
                  }else if(value.contains("-")){
                    return "El precio no puede contener guiones";
                  }
                  return null;
                }
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(top: 15),
                width: double.infinity,
                child: ElevatedButton( //Botón para confirmar la subida del producto si los campos son correctos
                  onPressed: () async{
                    FocusScope.of(context).requestFocus(FocusNode()); //quita el foco
                    if(!_images.any((image) => image != null)){ //si no hay ninguna imagen muestra el diálogo
                      showDialog(
                        context: context, 
                        builder: (_) => buildNeedPictureDialog()
                      );
                    }else if(_formKey.currentState?.validate() ?? false){ //el métedo validate valida los campos del formulario
                      widget.newProductModel.setName = _nameController.value.text;
                      widget.newProductModel.setDescription = _descriptionController.value.text;
                      widget.newProductModel.price = double.parse(_priceController.value.text);
                      List<String?> stringImages= await Future.wait(
                        _images.where((image) => image!=null).map((image) => cloudinaryService.uploadImageToCloudinary(image)).toList()
                      );
                      widget.newProductModel.setImages = stringImages;

                      await productService.addProduct(
                        widget.newProductModel, 
                        Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId!
                      );
                      await Navigator.pushReplacementNamed(context, "/home"); //vuelve a la página principal
                    } 
                  },
                  style: elevatedButtonStyle,
                  child: const Text(
                    'Guardar y Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
