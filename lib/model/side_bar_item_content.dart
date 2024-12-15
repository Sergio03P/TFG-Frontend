import 'package:flutter/material.dart';

//Clase que representa las opciones seleccionables en el menú lateral
class SideBarItemContent {
  final String title; //título de la opción
  final Icon icon; //icono de la opción
  final VoidCallback? onTapCallback; //método al pulsar sin contexto
  final Function(BuildContext)? onTapWithContext; //método al pulsar con el contexto

  //Construcor con parámetros
  SideBarItemContent({
    required this.title,
    required this.icon,
    this.onTapCallback,
    this.onTapWithContext,
  }): assert(
    (onTapCallback == null) != (onTapWithContext == null),
    'Debe proporcionar sólo uno: onTapCallback o onTapWithContext, pero no ambos.',
  );

  // Método que ejecuta el callback apropiado
  void onTap(BuildContext context) {
    if (onTapCallback != null) {
      onTapCallback!();
    } else if (onTapWithContext != null) {
      onTapWithContext!(context);
    }
  }
}