import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPasswordInput extends StatefulWidget {

  final TextEditingController passwordController;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomPasswordInput({
    super.key,
    required this.passwordController,
    this.inputFormatters,
    this.validator
  });

  @override
  State<CustomPasswordInput> createState() => _CustomPasswordInputState();
}

class _CustomPasswordInputState extends State<CustomPasswordInput> {
  bool hiddenPassword = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        suffixIcon: IconButton(
          icon: Icon(
            hiddenPassword == true
              ? Icons.lock_clock_outlined
              : Icons.lock_open_outlined,
          ),
            onPressed: () => setState(() {
              hiddenPassword = !hiddenPassword;
            }),
        ),
        border: const OutlineInputBorder()
      ),
      keyboardType: TextInputType.visiblePassword,
      obscureText: hiddenPassword,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator
    );
  }
}