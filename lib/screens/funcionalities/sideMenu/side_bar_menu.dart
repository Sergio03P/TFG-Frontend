// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/model/side_bar_item_content.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/TransactionsHistory/sales_history_screen.dart';
import 'package:prime_store/screens/funcionalities/TransactionsHistory/purchase_history_screen.dart';
import 'package:prime_store/screens/funcionalities/userProfile/user_profile_screen.dart';
import 'package:prime_store/screens/funcionalities/sideMenu/updateUserProfile/update_user_profile_screen.dart';
import 'package:prime_store/screens/funcionalities/wallet/wallet_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

//Menú de usuario lateral
class SideBarMenu extends StatefulWidget {
  final UserModel userAuthenticated; //usuario autenticado en la app

  const SideBarMenu({
    super.key,
    required this.userAuthenticated
  });

  @override
  State<SideBarMenu> createState() => _SideBarMenuState();
}

class _SideBarMenuState extends State<SideBarMenu> {
  @override
  void dispose() {
    UserProvider().logOut();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        width: 288,
        height: double.infinity,
        color: const Color(0xFF17203A),
        child: SafeArea(
          child: Column(
            children: [
              const ProfileCard(),  //perfil del usuario
              const SizedBox(height: 8),
              Text(
                "transacciones".toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white70)
              ),const Padding(
                padding: EdgeInsets.only(left: 24, top: 5, bottom: 16),
                child: Divider(color: Colors.white24, height: 0),
              ),
              ...sideBarItemsVol1.map((item) => SideMenuItem( //lista de opciones que tienen que ver con las transacciones
                  title: item.title, icon: item.icon, onTap:() => item.onTapWithContext!(context)
                )
              ),
              const SizedBox(height: 20),
              Text(
                "Perfil".toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white70),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24, top: 5, bottom: 16),
                child: Divider(color: Colors.white24, height: 0),
              ),
              ...sidebarItemsVol2.map((item) => SideMenuItem( //lista de opciones que tienen que ver con el perfil
                title: item.title, icon: item.icon, onTap: () => item.onTapWithContext!(context)))
            ],
          ),
        ),
      ),
    );
  }
}

//Opciones dentro del menú de usuario
class SideMenuItem extends StatelessWidget {
  final String title; //título
  final Icon icon; //icono
  final VoidCallback onTap; //evento al pulsar

  const SideMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [ 
        ListTile(
          leading: SizedBox(
            height: 34,
            width: 34,
            child: icon,
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white54),
          ),
          onTap: onTap,
        )
      ],
    );
  }
}

//Tarjeta con los datos del usuario autenticado
class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    return ListTile(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserProfile(userId: userProvider.getUserAuthenticatedId!, fromWhichScreen: "fromSideMenuToggle",))),
      leading: CircleAvatar(
        backgroundImage: userProvider.getUserAuthenticated?.profilePicture != null
          ? NetworkImage(userProvider.getUserAuthenticated!.profilePicture!)
          : null,
        child: userProvider.getUserAuthenticated?.profilePicture == null
          ? const Icon(Icons.person, color: Colors.white)
          : null, // Elimina el ícono si la imagen existe.
      ),
      title: Text(userProvider.getUserAuthenticated!.username, style: const TextStyle(color: Colors.white)),
      subtitle: Text(userProvider.getUserAuthenticated!.name, style: const TextStyle(color: Colors.white)),
    );
  }
}

//*Listas
List<SideBarItemContent> sideBarItemsVol1 = [
  SideBarItemContent(
    title: 'Compras',
    icon: const Icon(Icons.handshake, color: Colors.white54,),
    onTapWithContext: (context) {
      int? userAuthenticatedId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId; //!esto hay que centralizarlo
      if(userAuthenticatedId != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseHistoryScreen(userId: userAuthenticatedId)));
      }
    },
  ),
  SideBarItemContent(
    title: 'Ventas',
    icon: const Icon(Icons.price_change_outlined, color: Colors.white54),
    onTapWithContext: (context) {
      // Define la acción al pulsar el ítem
      int? userAuthenticatedId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId;
      if(userAuthenticatedId != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => SalesHistoryScreen(userId: userAuthenticatedId)));
      }
    },
  ),
  SideBarItemContent(
    title: 'Monedero',
    icon: const Icon(Icons.paid_rounded, color: Colors.white54),
    onTapWithContext: (context) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
    },
  ),
];

List<SideBarItemContent> sidebarItemsVol2 = [
  SideBarItemContent(
    title: "Editar perfil", 
    icon: const Icon(Icons.edit, color: Colors.white54),
    onTapWithContext: (context) async{
     UserModel? userModel = Provider.of<UserProvider>(context, listen: false).getUserAuthenticated;
     if(userModel != null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateUserProfileScreen(user: userModel)));
     }
    }
  ),
  SideBarItemContent(
    title: "Cerrar Sesión", 
    icon: const Icon(Icons.person_off_outlined, color: Colors.white54),
    onTapWithContext: (context) async{
      Provider.of<SideMenuProvider>(context, listen: false).setIsSIdeMenuClosed = true;
      await StreamChat.of(context).client.disconnectUser();
      await Navigator.pushReplacementNamed(context, "/");
    }
  )
];
