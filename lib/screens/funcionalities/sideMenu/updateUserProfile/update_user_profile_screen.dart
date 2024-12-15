// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_store/widgets/dialogs/custom_dialogs.dart';
import 'package:prime_store/widgets/formInputs/custom_input_field.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/services/cloudinary_service.dart';
import 'package:prime_store/services/user_service.dart';
import 'package:prime_store/styles/widgets_styles.dart';
import 'package:provider/provider.dart';

class UpdateUserProfileScreen extends StatefulWidget {
  final UserModel user;
  final String folderPath; // Carpeta en Cloudinary

  const UpdateUserProfileScreen({
    super.key,
    required this.user,
    this.folderPath = 'public/user_profiles', // Carpeta predeterminada
  });

  @override
  State<UpdateUserProfileScreen> createState() => _UpdateUserProfileScreenState();
}

class _UpdateUserProfileScreenState extends State<UpdateUserProfileScreen> {
  final _formKey = GlobalKey<FormState>(); //controlador del formulario
  final ImagePicker _picker = ImagePicker(); //libería para coger las imágenes
  final CloudinaryService cloudinaryService = CloudinaryService();

  //controladores para cada campo de texto
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _firstnameAndLastNameController;
  late TextEditingController _postalCodeController;

  //Mensajes que se muestran si existe algún error al actualizar los datos
  String? usernameError;
  String? emailError;

  File? _profileImage; //foto de perfil

  @override
  void initState() { //inicializamos los controladores
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _nameController = TextEditingController(text: widget.user.name);
    _firstnameAndLastNameController = TextEditingController(text: '${ widget.user.firstname} ${widget.user.lastname}');
    _postalCodeController = TextEditingController(text: widget.user.postalCode.toString());
  }

  @override
  void dispose() { //liberamos los recursos
    _usernameController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _firstnameAndLastNameController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  //Valida que la información del usuario que lo identifica esté disponible
  Future<void>validateUsernameAndEmail() async{
    if(_usernameController.text.trim().isNotEmpty && _usernameController.text.trim() != widget.user.username.trim()){
      try{
        final UserModel? userFromUsername = await UserService().getUserByUsername(_usernameController.text.trim());
        if(userFromUsername != null){
          setState(() {
            usernameError = "El nombre de usuario ya existe";
          });
        }
      }on DioException{
        //
      }
    }
    if(_emailController.text.trim().isNotEmpty && _emailController.text.trim() != widget.user.email.trim()){
      try{
        final UserModel? userFromEmail = await UserService().getUserByEmail(_emailController.text.trim());
        if(userFromEmail != null){
          setState(() {
            emailError = "El correo ya existe";
          });
        }
      }on DioException{
        //
      }
    }
  }

  //Método para seleccionar la foto de perfil
  Future<void> selectAvatar() async {
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de la galería'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await _picker.pickImage(source: ImageSource.gallery),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar una foto'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await _picker.pickImage(source: ImageSource.camera),
                  );
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Eliminar foto actual'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                      widget.user.profilePicture = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  //Método para guardar la imagen en cloudinary y añadirla al usuario
  Future<void> _saveProfile() async{
    if(_formKey.currentState!.validate()){
      String? uploadedImageUrl;
      if(_profileImage!= null){
        final uploadedImageUrl = await cloudinaryService.uploadImageToCloudinary(XFile(_profileImage!.path));
        if(uploadedImageUrl!= null){
          widget.user.profilePicture = uploadedImageUrl;
        }
      }

      final updatedUser = UserModel( //usuario a actualizar en la BBDD
        id: widget.user.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        firstname: _firstnameAndLastNameController.text.split(' ')[0],
        lastname: _firstnameAndLastNameController.text.split(' ')[1],
        postalCode: int.parse(_postalCodeController.text.trim()),
        role: widget.user.role,
        registerDate: widget.user.registerDate.trim(),
        profilePicture: uploadedImageUrl ?? widget.user.profilePicture,
      );

      UserModel user = await UserService().updateUser(updatedUser);
      bool isOk = await Provider.of<UserProvider>(context, listen: false).updateAuthenticatedUser(user);
      if(isOk){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => buildCustomSuccessDialog(//Diálogo de confirmación
            context, 
            "Usuario actualizado con éxito",  
            1
          )
        );
        final sideMenuProvider = Provider.of<SideMenuProvider>(context, listen: false);
        sideMenuProvider.toggleSideMenu();
        await Navigator.pushReplacementNamed(context, "/home");
      }else{
        //Diálogo de error al actualizar al usuario
        await showDialog(
          context: context, 
          builder: (_) => buildCustomErrorDialog(
            context, 
            "Error al editar", 
            "Ha ocurrido un error insesperado al intentar editar la información del usuario", 
            1
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar Información del usuario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: selectAvatar,
                    child: CircleAvatar(
                      radius: 61,
                      backgroundColor: Colors.teal,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : widget.user.profilePicture != null
                                ? NetworkImage(widget.user.profilePicture!)
                                : null,
                        child: _profileImage == null &&
                                widget.user.profilePicture == null
                            ? const Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _usernameController, 
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.person,
                  labelText: "Nombre de usuario",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre de usuario es obligatorio';
                    }
                    if (value.length < 6) {
                      return 'El nombre de usuario debe tener al menos 6 carácteres';
                    }
                    if(usernameError != null){
                      return usernameError;
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _emailController,
                  labelText: 'Correo',
                  hintText: 'example@gmail.com',
                  isPassword: false,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }
                    if (!value.endsWith('@gmail.com')) {
                      return 'El correo debe terminar con "@gmail.com"';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                      return 'Correo electrónico no válido';
                    }
                    if(emailError != null){
                      return emailError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _nameController,
                  labelText: 'Nombre',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (value.length < 4) {
                      return 'El nombre debe tener al menos 4 carácteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _firstnameAndLastNameController,
                  labelText: 'Apellidos',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Los apellidos son obligatorios';
                    }
                    // Validar que haya un espacio y que se ingresen exactamente dos palabras
                    List<String> apellidos = value.trim().split(' ');
                    if (apellidos.length != 2) {
                      return 'Debe ingresar exactamente dos apellidos separados por un espacio';
                    }
                    if (apellidos.any((apellido) => apellido.length < 2)) {
                      return 'Cada apellido debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _postalCodeController,
                  labelText: 'Código postal',
                  prefixIcon: Icons.location_on_sharp,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El código postal es obligatorio';
                    }
                    if (value.length != 5) {
                      return 'El código postal debe tener una longitud de 5 dígitos';
                    }
                    if (!RegExp(r'^[0-9]{5}$').hasMatch(value)) {
                      return 'El código postal debe ser numérico y tener 5 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async{
                      setState(() {
                        usernameError = null;
                        emailError = null;
                      });
                      await validateUsernameAndEmail();
                      await _saveProfile();
                      
                    },
                    style: elevatedButtonStyle,
                    child: const Text("Guardar cambios", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
