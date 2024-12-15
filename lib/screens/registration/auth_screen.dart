// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:prime_store/screens/registration/register_screen.dart';
import 'package:prime_store/services/auth_service.dart';
import 'package:prime_store/services/user_service.dart';
import 'package:prime_store/widgets/formInputs/custom_input_field.dart';
import 'package:prime_store/widgets/formInputs/custom_password_input.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  bool? isEmailLoginSelected;
  bool hiddenPassword = true;
  bool isLoading = false;

  String? _usernameErrorText; // Mensaje de error para el campo de usuario

  //Controladores de inicio de sesión
  final  TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final usernameInputFormatter = MaskTextInputFormatter(
    mask: '****************',  // Solo permitir 16 caracteres alfanuméricos
    filter: {"#": RegExp(r'[a-zA-Z0-9_]')},  // Sólo letras, números y guion bajo
  );

  // Formato para el campo de contraseña (se puede personalizar más si se desea)
  final passwordInputFormatter = MaskTextInputFormatter(
    mask: '************************',  // Contraseña con hasta 16 caracteres
    filter: {"#": RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]')},  // Permitimos letras, números y caracteres especiales
  );

  //clave para manejar el estado del fromulario
  final GlobalKey<FormState> _formKey = GlobalKey();

  final AuthService authService = AuthService();
  final UserService userService = UserService();

  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async{
    
    setState(() {
      _usernameErrorText = null;
      isLoading = true;
    });
    
    if(_formKey.currentState?.validate() ?? false){
      try{
        await authService.login(
          _usernameController.text.toLowerCase().trim(), 
          _passwordController.text.trim()
        );
        UserModel? userModel = await userService.getUserByUsername(_usernameController.text.toLowerCase().trim());
        await Provider.of<UserProvider>(context, listen:false).retrieveAuthenticatedUser(userModel!.username);
        await Provider.of<WalletProvider>(context, listen: false).retrieveWallet(userModel.id);
        String? jwtChatToken = await _secureStorage.read(key: "jwtChatToken");
        final client = StreamChat.of(context).client;
        await client.connectUser(User(id: userModel.username), jwtChatToken!);
        
        Navigator.pushReplacementNamed(context, "/home");

      }on DioException catch(dioError){
        if (dioError.response?.statusCode == 403){
          setState(() {
            _usernameErrorText = "No existe una cuenta para el usuario y contraseña";
          });
          _formKey.currentState?.validate();
        } else {
        }
      }finally{
        isLoading = false;
      }
    }                     
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 15),
                    child: Center(
                      child: Text(
                        'Bienvenido',
                        style: TextStyle(fontSize: 27, color: Colors.white),
                      ),
                    ),
                  ),
                  Text(
                    'Inicie sesión para continuar',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            // ** FIN DEL CARTEL DE BIENVENIDA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12), // Un único padding alrededor de todo el contenido
              child: Form(
                key:_formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 25), // Espaciado inicial
                    const SizedBox(height: 15),
                    CustomInputField( //? usuario label input
                      controller: _usernameController,
                      suffixIcon: Icons.person,
                      labelText: "Escriba su usuario",
                      keyboardType: TextInputType.text, 
                      validator: (value){
                        if(_usernameErrorText != null){
                          return '';
                        }
                        return null;
                      }
                    ),
                    SizedBox(height: _usernameErrorText == null ? 20 : 0), 
                    CustomPasswordInput(
                      passwordController: _passwordController,
                      validator: (value){
                        if(_usernameErrorText != null){
                          return _usernameErrorText;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'o',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Text(
                            '¿No tienes cuenta?',
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const RegisterScreen())
                              );
                            }, 
                            child: const Text(
                              'Registrate',
                              style: TextStyle(
                                color: Colors.lightBlue
                              )
                            )
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(height: _usernameErrorText == null ? 100 : 80),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        height: 65,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await login();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white,))
              : const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}