import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/buyProduct/tabs/order_summary_tab.dart';
import 'package:prime_store/screens/funcionalities/buyProduct/tabs/payment_method_tab.dart';
import 'package:provider/provider.dart';

/// Clase que contiene los tabs que conforman las pantallas para recoger la información del
/// producto y subirla a la aplicación
class BuyProductScreen extends StatefulWidget {
  final ProductModel selectedProduct; //producto seleccionado para comprar

  //Constructor
  const BuyProductScreen({
    super.key,
    required this.selectedProduct
  });

  @override
  State<BuyProductScreen> createState() => _BuyProductScreenState();
}

class _BuyProductScreenState extends State<BuyProductScreen> with SingleTickerProviderStateMixin{
  late final TabController tabController; //controlador de los tabs
  final int index = 0; //índice para mostrar los tabs
  late final TransactionModel newTransactionModel; //modelo de transacción asociada a la compra del producto


  @override
  void initState() {
    super.initState();
    tabController = TabController( //inicialización del tabController
      length: 2, //número de tabs
      vsync: this, //referencia a la propia clase
      initialIndex: index //índice del tab actual
    );
    newTransactionModel = TransactionModel.defaultConstructor();
    int? buyerId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId;
    if (buyerId != null) newTransactionModel.buyerId = buyerId;
    newTransactionModel.sellerId = widget.selectedProduct.ownerUserId;
    newTransactionModel.productId = widget.selectedProduct.id;
  }

  @override
  void dispose() {//se liberan los recursos
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( //controla que la UI no se desborde fuuera de los márgenes
        child: Column(
          children: [
            Expanded(
              child: TabBarView( //dentro de él se definen los tabs a mostrar
                controller: tabController, //controlador de los tabs
                physics: const NeverScrollableScrollPhysics(), //desactivar la navegación entre pantallas al deslizar
                children: [
                  PaymentMethodTab(tabController: tabController, newTransactionModel: newTransactionModel,selectedProduct: widget.selectedProduct),
                  OrderSummaryTab(tabcontroller: tabController, newTransactionModel: newTransactionModel, selectedProduct: widget.selectedProduct)
                ]
              ),
            ),
          ],
        )
      )
    );
  }
}