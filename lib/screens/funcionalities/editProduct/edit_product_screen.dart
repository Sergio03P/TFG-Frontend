// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/services/cloudinary_service.dart';
import 'package:prime_store/services/product_service.dart';
import 'package:prime_store/widgets/formInputs/custom_input_field.dart';

//Pantalla para editar el producto seleccionado
class EditProductScreen extends StatefulWidget {
  final ProductModel selectedProduct; //Producto que vamos a editar

  //Constructor
  const EditProductScreen({
    super.key, 
    required this.selectedProduct
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>(); //controlador del formulario
  //Campos de texto para introducir valores
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  final ImagePicker _picker = ImagePicker(); //librería para seleccionar imágenes
  final List<XFile?> _images = List<XFile?>.filled(8, null,growable: true); // Imágenes que el usuario seleccionará
  final List<String?> _oldImages = List<String?>.filled(8, null, growable: true); //lista de imágenes anteriores

  @override
  void initState() { //inicializamos los campos de texto
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() { //liberamos los recursos
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  //Construye el diálogo que se muestra si no has introducido una imagen
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
              )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>{
            Navigator.pop(context),
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  // Función para seleccionar imágenes
  Future<void> _selectImage(int index) async {
    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      builder: (context) => _buildBottomSheet(),
    );

    if (image != null) {
      setState(() {
        _images[index] = image; //imagen seleccionada
        _oldImages[index] = null; //elimina la imagen que había anteriormente para intercambiarlo por la nueva
      });
    }
  }

  //Llama al modal y construye el bottomSheet
  Future<void> _dropImage(int index) async {
    await showModalBottomSheet<XFile>(
      context: context,
      builder: (context) => _buildRemovePictureBottomSheet(index)
    );
  }

  //Contenido del modal para eliminar la foto
  Widget _buildRemovePictureBottomSheet(int index){
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 3),
      child: ListTile(
        leading: const Icon(Icons.delete_outline_outlined),
        title: const Text("Eliminar la foto actual"),
        onTap: (){
          _images[index] = null;
          _oldImages[index] = null;
          widget.selectedProduct.images[index] = null;
          Navigator.pop(context);
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
            //Selecciona la imagen desde la cámara
            final XFile? image = await _picker.pickImage(source: ImageSource.camera);
            Navigator.pop(context, image);//cierra el modal
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo),
          //Selecciona la imagen desde la galería
          title: const Text('Elegir de la Galería'),
          onTap: () async {
            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
            Navigator.pop(context, image); //cierra el modal
          },
        ),
      ],
    );
  }

  //Método que actualiza el producto en la BBDD
  Future<ProductModel?> updateProduct() async{
    //Se asignan los valores del producto que se va a actualizar
    ProductModel newProductModel = ProductModel.defaultConstructor();
    newProductModel.setId = widget.selectedProduct.id;
    newProductModel.setName = _nameController.text.toString();
    newProductModel.setDescription = _descriptionController.text.toString();
    newProductModel.setPrice = double.parse(_priceController.text.toString());
    newProductModel.setDate = widget.selectedProduct.date;
    newProductModel.category == widget.selectedProduct.category; //?
    List<String?> newImagesList = _oldImages.where((image) => image != null).toList();
    newImagesList.addAll(  //añades las urls donde se alojan las imágenes en cloudinary
      await Future.wait(_images
        .where((image) => image != null)
        .map((image) => CloudinaryService().uploadImageToCloudinary(image))
        .toList()
      )
    );
    newProductModel.setImages = newImagesList;
    newProductModel.setOwnerUserId = widget.selectedProduct.ownerUserId;
    return ProductService().updateProduct(newProductModel); //Actualiza el producto en la BBDD
  }

  //GridView de las imágenes
  Widget _buildImageGrid() {
  return GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1,
    ),
    itemCount: _images.length,
    itemBuilder: (context, index) {
      // Verificar si el índice está dentro del rango de imágenes del producto
      if (index < widget.selectedProduct.images.length) {
        return GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
            _selectImage(index);
          },
          onLongPress: (){
            FocusScope.of(context).requestFocus(FocusNode()); 
            if(_images[index] != null || _oldImages[index] != null){
              _dropImage(index);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[300],
            ),
            child: _images[index] == null  /* && _images[index]!.path.isNotEmpty */ 
                  ?(_oldImages[index] != null && _oldImages[index]!.isNotEmpty)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                          _oldImages[index]!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if(loadingProgress == null){
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                                color: Colors.lightBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.grey);
                          },
                        ),
                    )
                    : const Icon(Icons.add_a_photo, color: Colors.grey)
                 : Image.file(
                    File(_images[index]!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  )
          )
        );
      } else {
        // Si el índice está fuera del rango de las imágenes del producto, mostramos un icono por defecto
        return GestureDetector(
          onTap: () => _selectImage(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[300],
            ),
            child: _images[index] != null && _images[index]!.path.isNotEmpty
                ? Image.file(
                    File(_images[index]!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  )
                : const Icon(Icons.add_a_photo, color: Colors.grey),
          ),
        );
      }
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(const Duration(milliseconds: 200)),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.lightBlue,)));
        } else {
          widget.selectedProduct.images.asMap().forEach((index, image) {
            if (image != null && !_oldImages.contains(image)) {
              _oldImages[index] = image;
            }
          });
          // Inicializar los campos con los valores del producto
          _nameController.text = widget.selectedProduct.name;
          _descriptionController.text = widget.selectedProduct.description;
          _priceController.text = widget.selectedProduct.price.toString();
          return Scaffold(
            appBar: AppBar(
              title: const Text("Editar producto"),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Cuadrícula de imágenes
                        _buildImageGrid(),
                        const SizedBox(height: 20),
                        CustomInputField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          labelText: "Nombre",
                          validator:(value){
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
                              return "La descripción es demasiado corta (mínimo 10 letras)";
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),  
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ElevatedButton(
                onPressed:() async{
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(!_images.any((image) => image != null) && !_oldImages.any((image) => image != null)){
                    buildNeedPictureDialog();
                  }else if(_formKey.currentState?.validate() ?? false){
                    final ProductModel? updatedProduct = await updateProduct();
                    Navigator.pop(context, updatedProduct);
                  } 
                }, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.teal, // Color del botón
                ),
                child: const Text(
                  'Confirmar edición',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
