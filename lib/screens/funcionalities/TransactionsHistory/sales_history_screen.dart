import 'package:flutter/material.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/transaction_seller_provider.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class SalesHistoryScreen extends StatefulWidget {
  final int userId; //id de usuario que quiere  visualizar sus ventas

  //Constructor
  const SalesHistoryScreen({super.key, required this.userId});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  @override
  void initState() {
    super.initState();
    //Obtenemos las transacciones
    Provider.of<TransactionSellerProvider>(context, listen: false)
        .retrieveSellerTransactionsList(widget.userId);
  }

  //Método para volver a cargar las transacciones
  Future<void> loadTransactions() async{
    await Provider.of<TransactionSellerProvider>(context, listen: false).retrieveSellerTransactionsList(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final sideMenuProvider = Provider.of<SideMenuProvider>(context, listen: false);
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Historial de Ventas"),
          leading: IconButton(
            onPressed: () async{
              sideMenuProvider.toggleSideMenu(); //cierra el menú lateral
              Provider.of<BottomIndexNavigationProvider>(context, listen: false).setIndex = 0;
              await Navigator.pushReplacementNamed(context, "/home");
            }, 
            icon: const Icon(Icons.arrow_back)
          ),
          bottom: const TabBar( //tabBar que muestran las transacciones pendientes y finalizadas
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            tabs: [
              Tab(text: "En curso"),
              Tab(text: "Finalizadas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(TransactionState.PENDING),
            _buildTransactionList(TransactionState.COMPLETED),
          ],
        ),
      ),
    );
  }

  // Construir la lista de transacciones en función del estado seleccionado
  Widget _buildTransactionList(TransactionState state) {
    return Consumer<TransactionSellerProvider>(
      builder: (context, provider, child) {
        // Filtramos las transacciones en función del estado seleccionado
        final transactions = provider.sellerTransactionsList
            .where((transaction) => transaction.transactionState == state)
            .toList();

        if (transactions.isEmpty) {
          // Si no hay transacciones para el estado seleccionado mostramos un mensaje
          return Center(
            child: Text(
              state == TransactionState.PENDING
                  ? "No hay transacciones en curso."
                  : "No hay transacciones completadas.",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold ,color: Colors.grey),
            ),
          );
        }

        // Agrupamos las transacciones por mes
        final transactionsByMonth = _groupByMonth(transactions);

        return ListView.builder( //list view con las transacciones agrupadas por mes
          itemCount: transactionsByMonth.length,
          itemBuilder: (context, index) {
            final month = transactionsByMonth.keys.elementAt(index);
            final monthTransactions = transactionsByMonth[month]!;
        
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    month, // Nombre del mes en español
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder( //ListView con las transacciones que pertenecen al mes concreto
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = monthTransactions[index];
                    return FutureBuilder<ProductModel>(
                      future: Provider.of<ProductListProvider>(context,
                              listen: false)
                          .getProductById(transaction.productId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text("Cargando producto..."),
                          );
                        } else if (snapshot.hasError) {
                          return const ListTile(
                            title: Text("Error al cargar producto"),
                          );
                        } else {
                          final product = snapshot.data!;
                          return _buildTransactionItem(
                            product, 
                            transaction,
                            monthTransactions.length,
                            index
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función para agrupar las transacciones por mes
  Map<String, List<TransactionModel>> _groupByMonth(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> transactionsByMonth = {};
    transactions.sort((a, b) => b.date.compareTo(a.date)); // Orden descendente por fecha

    for (var transaction in transactions) {
      // Parseamos la fecha utilizando el formato correcto
      final parsedDate = DateFormat("dd/MM/yyyy HH:mm:ss").parse(transaction.date);

      // Formato del mes en español
      final month = DateFormat("MMMM yyyy", 'es').format(parsedDate);
      
      if (!transactionsByMonth.containsKey(month)) {
        transactionsByMonth[month] = [];
      }
      transactionsByMonth[month]!.add(transaction);
    }

    final sortedMap = Map.fromEntries( //pone en primer lugar las transacciones más recientes
      transactionsByMonth.entries.toList()..sort((a,b) => a.key.compareTo(b.key))
    );

    return sortedMap;
  }

  // Widget para construir el ítem de una transacción con la imagen del producto y botón de confirmación
  Widget _buildTransactionItem(
    ProductModel product, 
    TransactionModel transaction,
    int length,
    int index) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: SizedBox(
              width: 60,
              height: 60,
              child: product.images.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                        product.images.first!, //imagen del producto
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if(loadingProgress == null){
                            return child;
                          }else{
                            return Center( //barra de progreso mientras cargan las imágenes
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                                color: Colors.lightBlue,
                              ),
                            );
                          }
                        },
                      ),
                  )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            subtitle: Text(product.description),
            trailing: Text(
              "${transaction.totalPrice.toString()} €",
              style: const TextStyle(fontSize: 17),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: (length -1) == index
                ? null
                : const Divider()
            ),
            SizedBox(
              height: (length -1) != index
                ? null
                : 35
            )
        ],
      );
  }
}
