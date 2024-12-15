// ignore_for_file: use_build_context_synchronously
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/transaction_buyer_provider.dart';
import 'package:prime_store/screens/funcionalities/TransactionsHistory/confirm_transaction.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final int userId; //id del usuario que comprueba las compras

  //Constructor
  const PurchaseHistoryScreen({super.key, required this.userId});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  late final ConfettiController _confettiController; //controlador del confeti
  bool isPlaying = false; //boleano que comprueba si sigue activa la animación de confeti

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1000));
    Provider.of<TransactionBuyerProvider>(context, listen: false) //obtiene la lista de transacciones de compra
      .retrieveBuyerTransactionsList(widget.userId);
  }

  @override
  void dispose() { //se liberan los recursos
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sideMenuProvider = Provider.of<SideMenuProvider>(context, listen: false);
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Historial de Compras"),
          leading: IconButton(
            onPressed: () async{
              sideMenuProvider.toggleSideMenu(); //cierra el menú lateral
              Provider.of<BottomIndexNavigationProvider>(context, listen:false).setIndex = 0;
              await Navigator.pushReplacementNamed(context, "/home");
            }, 
            icon: const Icon(Icons.arrow_back)
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            tabs: [
              Tab(text: "En curso"),
              Tab(text: "Finalizadas"),
            ],
          ),
        ),
        body: Stack(alignment: Alignment.topCenter, children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality:
                BlastDirectionality.explosive, // Tipo de explosión
            shouldLoop: false,
            //colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.yellow],
            emissionFrequency: 0.25,
          ),
          TabBarView(
            children: [
              _buildTransactionList(TransactionState.PENDING),
              _buildTransactionList(TransactionState.COMPLETED),
            ],
          ),
        ]),
      ),
    );
  }

  // Construir la lista de transacciones en función del estado seleccionado
  Widget _buildTransactionList(TransactionState state) {
    return Consumer<TransactionBuyerProvider>(
      builder: (context, provider, child) {
        // Filtramos las transacciones en función del estado seleccionado
        final transactions = provider.buyerTransactionsList
            .where((transaction) => transaction.transactionState == state)
            .toList();

        if (transactions.isEmpty) {
          // Si no hay transacciones para el estado seleccionado mostramos un mensaje
          return Center(
            child: Text(
              state == TransactionState.PENDING
                  ? "No hay transacciones en curso."
                  : "No hay transacciones completadas.",
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)
            ),
          );
        }
        // Agrupamos las transacciones por mes
        final transactionsByMonth = _groupByMonth(transactions);

        return ListView.builder( //construimos una lista con los productos
          itemCount: transactionsByMonth.length,
          itemBuilder: (context, index) {
            final month = transactionsByMonth.keys.elementAt(index);
            final monthTransactions = transactionsByMonth[month]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    month, //nombre del mes en español
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder( //lista de productos agrupados por el mes de la transacción
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = monthTransactions[index];
                    return FutureBuilder<ProductModel>(
                      future: Provider.of<ProductListProvider>(context,listen: false)
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
  Map<String, List<TransactionModel>> _groupByMonth(List<TransactionModel> transacciones) {
    final Map<String, List<TransactionModel>> transactionsByMonth = {};
    transacciones.sort((a, b) => b.date.compareTo(a.date)); // Orden ascendente por fecha

    for (var transaction in transacciones) {
      // Parseamos la fecha utilizando el formato correcto
      final parsedDate = DateFormat("dd/MM/yyyy HH:mm:ss").parse(transaction.date);

      // Formato del mes en español
      final month = DateFormat("MMMM yyyy", 'es').format(parsedDate);

      if (!transactionsByMonth.containsKey(month)) {
        transactionsByMonth[month] = [];
      }
      transactionsByMonth[month]!.add(transaction); //añadimos la transacción si contiene como clave el mes
    }
    
    final sortedMap = Map.fromEntries(
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
              height: 60,
              width: 60,
              child: product.images.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network( //imagen del producto
                        product.images.first!,
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
                            return Center(//barra de carga
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                                color: Colors.lightBlue,
                              )
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
          // Si la transacción está en estado PENDING, mostramos el botón de confirmación
          if (transaction.transactionState == TransactionState.PENDING)
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfirmTransaction(
                              transactionModel: transaction,
                              confettiController: _confettiController,
                            )));
              },
              child: Text("¿Ya recibiste el producto?", style: TextStyle(color: Colors.grey[700]),),
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
