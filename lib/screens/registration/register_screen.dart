// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prime_store/widgets/dialogs/custom_dialogs.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/model/data/wallet_model.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:prime_store/screens/registration/auth_screen.dart';
import 'package:prime_store/services/auth_service.dart';
import 'package:prime_store/services/user_service.dart';
import 'package:prime_store/services/wallet_service.dart';
import 'package:prime_store/widgets/formInputs/custom_input_field.dart';
import 'package:prime_store/widgets/upload_avatar.dart';
import 'package:prime_store/styles/widgets_styles.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;
  late final TextEditingController _firstAndLastNameController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _sexoController;

  bool hiddenPassword = true;
  File? image;
  String? usernameError;
  String? emailError;
  final AuthService authService = AuthService();
  final UserService userService = UserService();

  @override
  void initState() { //inicializamos los controladores de campo
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    _firstAndLastNameController = TextEditingController();
    _postalCodeController = TextEditingController();
    _sexoController = TextEditingController();
  }

  @override
  void dispose() { //liberamos recursos
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _firstAndLastNameController.dispose();
    _postalCodeController.dispose();
    _sexoController.dispose();
    super.dispose();
  }

  Future<void>validateUsernameAndEmail() async{
    if(_usernameController.text.isNotEmpty){
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
    if(_emailController.text.trim().isNotEmpty){
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

  Future<void> register() async{
    if(_formKey.currentState?.validate() ?? false){
      String firstname = _firstAndLastNameController.text.split(' ')[0];
      String lastname = _firstAndLastNameController.text.split(' ')[1];
      int castedPostalCode = int.parse(_postalCodeController.text);
      try{
        bool isRegisterSuccessful = await authService.register(
          _usernameController.text.trim(), 
          _emailController.text.trim(), 
          _passwordController.text.trim(), 
          _nameController.text.trim(), 
          firstname.trim(), 
          lastname.trim(), 
          castedPostalCode
        );

        if(isRegisterSuccessful){
          UserModel? userModel = await userService.getUserByEmail(_emailController.text.toLowerCase().trim());
          await Provider.of<UserProvider>(context, listen:false).retrieveAuthenticatedUser(userModel!.username);
          WalletModel newUserWallet = WalletModel(id: 0, amount: 0.0, userModelId: userModel.id);
          await WalletService().saveWallet(newUserWallet);
          await Provider.of<WalletProvider>(context, listen: false).retrieveWallet(userModel.id);
          if(!mounted) return;
          Navigator.pushReplacementNamed(context, "/home");
        }else{
          await showDialog(
            context: context, 
            builder: (_) => buildCustomErrorDialog(
              context,
              "Error al registrar usuario", 
              "Ha ocurrido un error inesperado al registrar al usuario", 
              1
            )
          );
        }
      } on DioException{
        await showDialog(
          context: context, 
          builder: (_) => buildCustomErrorDialog(
            context,
            "Error al registrar usuario", 
            "Ha ocurrido un error inesperado al registrar al usuario", 
            1
          )
        );
      }
    }
  }

  //**Métodos */
  void selectAvatar() async {
    image = await uploadUserAvatar(context);
    setState(() {});
  }

  Widget _buildDeleteImageDialog(){
    return AlertDialog(
      title: const Text("¿Desea eliminar la foto de perfil?"),
      actions: [
        TextButton(
          onPressed: (){
            setState(() {
              image = null;
            });
            Navigator.pop(context);
          }, 
          child: const Text("ACEPTAR", style: TextStyle(color:Colors.lightBlue, fontSize: 15))
        ),
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: const Text("CERRAR", style: TextStyle(color:Colors.lightBlue, fontSize: 15))
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: const Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                InkWell(
                    onTap: () => selectAvatar(),
                    onLongPress: image == null
                      ? null
                      : () async{
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => _buildDeleteImageDialog()
                          );
                        },
                    child: image == null
                        ? const CircleAvatar(
                            backgroundColor: Colors.teal,
                            radius: 60,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          )
                        : CircleAvatar(
                            radius: 61,
                            backgroundColor: Colors.teal,
                            child: CircleAvatar(
                              backgroundImage: FileImage(image!),
                              radius: 60,
                            ),
                          )),
                const SizedBox(
                  height: 20,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Credenciales',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                //campos de texto
                CustomInputField(
                  controller: _emailController,
                  labelText: 'Correo',
                  hintText: 'example@gmail.com',
                  isPassword: false,
                  suffixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }
                    if (!value.trim().endsWith('@gmail.com')) {
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
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  isPassword: true,
                  suffixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La contraseña es obligatoria';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _usernameController,
                  labelText: 'Nombre de usuario',
                  suffixIcon: Icons.person,
                  keyboardType: TextInputType.text,
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
                  },
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Datos personales',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                CustomInputField(
                  controller: _nameController,
                  labelText: 'Nombre',
                  suffixIcon: Icons.badge_outlined,
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
                  controller: _firstAndLastNameController,
                  labelText: 'Apellidos',
                  suffixIcon: Icons.badge_outlined,
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
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        controller: _sexoController,
                        labelText: 'Sexo',
                        suffixIcon: Icons.interests_outlined,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El sexo es obligatorio';
                          }
                          if (!['Masculino', 'Femenino'].contains(value)) {
                            return 'Sexo debe ser "Masculino" o "Femenino"';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomInputField(
                        controller: _postalCodeController,
                        labelText: 'Código postal',
                        suffixIcon: Icons.location_on_sharp,
                        keyboardType: TextInputType.streetAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El código es obligatorio';
                          }
                          if (value.length != 5) {
                            return 'Debe tener 5 dígitos';
                          }
                          // Validación de si el código postal solo contiene números
                          if (!RegExp(r'^[0-9]{5}$').hasMatch(value)) {
                            return 'Debe ser numérico';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('¿Ya tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,MaterialPageRoute(builder:(BuildContext context) => const AuthScreen())
                        );
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(color: Colors.lightBlue),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () async {
                        setState(() {
                          usernameError = null;
                          emailError = null;
                        });
                        await validateUsernameAndEmail();
                        await register();
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)
                      )
                    )
                  ),
                )
              ],
            )
          ),
      )),
    );
  }
}
