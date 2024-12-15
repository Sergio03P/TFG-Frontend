import 'package:flutter/material.dart';

//Clase que maneja el contexto global de apertura y cierre del menú lateral
class SideMenuProvider with ChangeNotifier {
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;
  bool isSideMenuClosed = true;

  void initialize(TickerProvider ticker) {
    _animationController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        notifyListeners();
      });

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );
  }

  void toggleSideMenu() {
    if (isSideMenuClosed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isSideMenuClosed = !isSideMenuClosed;
    notifyListeners();
  }

  double get animationValue => animation.value;
  double get scaleAnimationValue => scaleAnimation.value;
  set setIsSIdeMenuClosed(bool value) => isSideMenuClosed = value;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
