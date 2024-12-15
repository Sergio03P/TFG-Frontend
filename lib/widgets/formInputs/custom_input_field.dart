import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;  // Hacerlo opcional
  final String? hintText;  // Hacerlo opcional
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;  // Hacerlo opcional
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;  // Hacerlo opcional

  const CustomInputField({
    super.key,
    required this.controller,
    this.labelText,  // Opcional
    this.hintText,  // Opcional
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,  // Opcional
    required this.keyboardType,
    required this.validator,
    this.inputFormatters,  // Opcional
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool hiddenPassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? hiddenPassword : false, // Mostrar o ocultar contraseña
      decoration: InputDecoration(
        labelText: widget.labelText,  // Si no se proporciona, no aparecerá el label
        hintText: widget.hintText ?? '', // Usar un valor por defecto si no se proporciona hintText
        prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon)
          : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  hiddenPassword ? Icons.lock_outline : Icons.lock_open_outlined,
                ),
                onPressed: () {
                  setState(() {
                    hiddenPassword = !hiddenPassword;
                  });
                },
              )
            : widget.suffixIcon != null
                ? Icon(widget.suffixIcon)  // Si hay un icono, lo mostramos
                : null,  // Si no hay un icono, no mostramos nada
        border: const OutlineInputBorder(),
      ),
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,  // Aplica los inputFormatters si se pasan
    );
  }
}
