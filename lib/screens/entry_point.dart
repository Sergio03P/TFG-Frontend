import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/sideMenu/side_bar_menu.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'home_page_screen.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> with TickerProviderStateMixin {
  late final AnimationController _borderController;
  late final Animation<double> _borderRadiusAnimation;
  @override
  void initState() {
    super.initState();
    Provider.of<SideMenuProvider>(context, listen: false).initialize(this);
    _borderController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300)
    );
    _borderRadiusAnimation = Tween<double>(begin: 0, end: 20)
      .animate(CurvedAnimation(parent: _borderController, curve: Curves.easeInOut));

  }

  Future<bool?> _buildPopScopeDialog(){
    return showDialog(
      context: context, 
      builder: (_) {
        return AlertDialog(
          title: const Text("¿Quieres salir de Prime Store?"),
          actions: [
            TextButton(
              onPressed: (){
                exit(0);
              }, 
              child: const Text("SALIR", style: TextStyle(fontSize: 15, color: Colors.lightBlue))
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context, false);
              }, 
              child: const Text("CERRAR", style: TextStyle(fontSize: 15, color: Colors.lightBlue))
            )
          ],
        );
      } 
    );
    
  }

  @override
  Widget build(BuildContext context) {
    final sideMenuProvider = Provider.of<SideMenuProvider>(context);
    final UserModel? userAuthenticated = Provider.of<UserProvider>(context, listen: false).getUserAuthenticated; //!esta como true

    if(sideMenuProvider.isSideMenuClosed){
      _borderController.reverse();
    }else{
      _borderController.forward();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(didPop){
          return;
        }
        final shouldPop = await _buildPopScopeDialog() ?? false;
        if(mounted && shouldPop){
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF17203A),
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              width: 288,
              left: sideMenuProvider.isSideMenuClosed ? -288 : 0,
              height: MediaQuery.of(context).size.height,
              child: SideBarMenu(userAuthenticated: userAuthenticated!,),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(sideMenuProvider.animationValue - 25 * sideMenuProvider.animationValue * pi / 180),
              child: Transform.translate(
                offset: Offset(sideMenuProvider.animationValue * 288, 0),
                child: Transform.scale(
                  scale: sideMenuProvider.scaleAnimationValue,
                  child: AnimatedBuilder(
                    animation: _borderController,
                    builder: (context, child){
                      return ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(_borderRadiusAnimation.value)),
                        child: const HomePageScreen(),
                      );
                    }
                    
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn, //fastOutSlowIn
              left: sideMenuProvider.isSideMenuClosed ? 420 : 240,
              top: 16,
              child: SideMenuFloatingButton(
                onTap: () {
                  sideMenuProvider.toggleSideMenu();
                  Provider.of<BottomIndexNavigationProvider>(context,listen: false).setIndex = 0;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SideMenuFloatingButton extends StatelessWidget {
  final VoidCallback onTap;

  const SideMenuFloatingButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          height: 30,
          width: 30,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.close),
        ),
      ),
    );
  }
}