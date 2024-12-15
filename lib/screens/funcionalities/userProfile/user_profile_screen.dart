// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/transaction_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/userProfile/tabs/user_products_tab.dart';
import 'package:prime_store/screens/funcionalities/userProfile/tabs/user_review_tab.dart';
import 'package:prime_store/services/product_service.dart';
import 'package:prime_store/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

//Clase que representa el perfil del usuario
class UserProfile extends StatefulWidget {
  final int userId; //id del perfil de usuario
  final String fromWhichScreen; //screen desde la que se llama al perfil del usuario

  //Constructor
  const UserProfile({
    super.key,
    required this.userId,
    required this.fromWhichScreen
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with SingleTickerProviderStateMixin{
  late final Future<List<dynamic>>future; //future para el builder
  late final TabController tabController; //controlador del tab
  final int index = 0; //índice del tab
  double averageRating = 0; //media de valoraciones

  //Método para cargar los datos necesarios de la BBDD en el FutureBuilder
  Future<List<dynamic>>_fechData() async{
      final UserModel user = await UserService().getUserById(widget.userId);
      final List<ProductModel> productList = await ProductService().getAllOnSaleProductsFromIdUser(user.id);
      final List<TransactionModel> transactionList = await Provider.of<TransactionProvider>(context, listen: false).retrieveTransactionsList(widget.userId);
      return [user, productList, transactionList];
    }

  @override
  void initState() {
    super.initState();
    future = _fechData();
    tabController = TabController( //Se crea el TabController
      length: 2, //número de tabs
      vsync: this, //referencia a esta clase
      initialIndex: index //posición del tab
    );
  }

  @override
  void dispose() { //liberamos los recursos
    tabController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    // Usar FutureBuilder para obtener las transacciones
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron transacciones')),
          );
        } else {
          final UserModel user = snapshot.data![0];
          final List<ProductModel> productsOnSaleList = snapshot.data![1];
          final List<TransactionModel> transactionList = snapshot.data![2];
          

          // Filtrar las transacciones con valoraciones
          transactionList.retainWhere((transaction) => transaction.sellerId == user.id); //todo
          var reviewTransactions = transactionList.where((t) => t.reviewModel != null).toList();
          int numberOfPurchases = transactionList.where((transaction) {
            return transaction.buyerId == user.id && transaction.transactionState == TransactionState.COMPLETED;
          }).toList().length;
          int numberOfSales = transactionList.where((transaction) {
           return transaction.sellerId == user.id && transaction.transactionState == TransactionState.COMPLETED;
          }).toList().length;

          //obtenemos el proveedor del menú lateral
          final sideMenuProvider = Provider.of<SideMenuProvider>(context);

          if (reviewTransactions.isNotEmpty) {
            averageRating = reviewTransactions
                    .map((t) => t.reviewModel!.rate)
                    .reduce((a, b) => a + b) /
                reviewTransactions.length;
          } else {
            averageRating = 0;
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: widget.fromWhichScreen == "fromSideMenuToggle" || widget.fromWhichScreen == "fromDeleteProduct"
                    ?(() async{
                      int userAuthenticatedId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId!;
                      await Provider.of<ProductListProvider>(context, listen: false).retrieveProductsOnSale(userAuthenticatedId);
                      Provider.of<BottomIndexNavigationProvider>(context,listen: false).setIndex = 0;
                      sideMenuProvider.toggleSideMenu();
                      await Navigator.pushReplacementNamed(context, "/home");
                    })
                    : ((){
                      Navigator.pop(context);
                    }),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Información del usuario
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '${user.name.capitalize()} ${user.firstname.substring(0, 1).toUpperCase()}.',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    RatingBar.builder(
                                      initialRating: averageRating, // Ejemplo: promedio de calificaciones
                                      ignoreGestures: true,
                                      allowHalfRating: true,
                                      direction: Axis.horizontal,
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {},
                                    ),
                                    const SizedBox(width: 4),
                                    Text("(${reviewTransactions.length})"),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: Text(user.username),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : null,
                        child: user.profilePicture == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Número de compras
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_cart, size: 20, color: Colors.blueGrey,), //todo grey 600
                              const SizedBox(width: 6),
                              Text('$numberOfPurchases compras'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Número de ventas
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.sell, size: 20,color: Colors.blueGrey,),
                              const SizedBox(width: 6),
                              Text('$numberOfSales ventas'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Código postal
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 20,color: Colors.blueGrey,),
                              const SizedBox(width: 6),
                              Text('CP: ${user.postalCode}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  TabBar(
                    controller: tabController,
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,     
                    tabs: const [
                      Tab(text: "En venta"),
                      Tab(text: "Valoraciones",)
                    ] 
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: UserProductsTab(userId: widget.userId,),
                        ),
                        UserReviewTab(tabController: tabController, productModelList: productsOnSaleList, transactionList: transactionList)
                      ]
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}