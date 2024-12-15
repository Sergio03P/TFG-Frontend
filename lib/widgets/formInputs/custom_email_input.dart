import 'package:flutter/material.dart';

class CustomEmailInput extends StatefulWidget {

  final TextEditingController emailController;

  const CustomEmailInput({
    super.key,
    required this.emailController
  });

  @override
  State<CustomEmailInput> createState() => _CustomEmailInputState();
}

class _CustomEmailInputState extends State<CustomEmailInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.emailController,
      decoration: const InputDecoration(
        hintText: 'example@gmail.com',
        labelText: 'Correo',
        suffixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder()
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value){
      if (value == null || value.trim().isEmpty) {
        return 'Campo obligatorio';
      }
      if(!value.endsWith('@gmail.com')){
        return 'El correo debe terminar con "@gmail.com"';
      }
        return null;
      },
    );
  }
}