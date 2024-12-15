// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/wallet_model.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:prime_store/services/fee_service.dart';
import 'package:prime_store/widgets/buyProduct/sumary_product_widget.dart';
import 'package:provider/provider.dart';

class PaymentMethodTab extends StatefulWidget {
  final TabController tabController;
  final TransactionModel newTransactionModel;
  final ProductModel selectedProduct;

  const PaymentMethodTab({
    super.key,
    required this.tabController,
    required this.newTransactionModel,
    required this.selectedProduct
  });

  @override
  State<PaymentMethodTab> createState() => _PaymentMethodTabState();
}

List<String> options = ["wallet", "card"];

class _PaymentMethodTabState extends State<PaymentMethodTab> {
  String currentOption = options[0];
  late final Future<List<dynamic>> future;

  Future<List<dynamic>> _fechData() async{
    final feeList = await FeeService().getFees();
    //final int? userAuthenticathedId = await Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId;
    WalletModel walletFromUserAuthenticated = Provider.of<WalletProvider>(context, listen: false).getWalletModel;
    return [feeList, walletFromUserAuthenticated];
  }

  void _buildWalletDialog(BuildContext context, WalletModel walletFromUserAuthenticathed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sin bordes redondeados
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "images/emptyWallet_04.gif",
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Fondos insuficientes',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tienes fondos suficientes para comprar el producto.'
                      '\nTu saldo actual del monedero es ${walletFromUserAuthenticathed.amount}€'
                      '\nCambia el método de pago.',
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CERRAR',style: TextStyle(color: Colors.lightBlue),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  void initState() {
    super.initState();
    future = _fechData();
    /* Future.microtask(() async{
      widget.newTransactionModel.setFees = await FeeService().getFees();
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: Colors.lightBlue));
        }else if(snapshot.hasError){
          return Center(child: Text('Error: ${snapshot.error}'));
        }else if(!snapshot.hasData){
          return const Center(child: Text('No se han podido obtener los datos'));
        }else{
          widget.newTransactionModel.setFees = snapshot.data![0];
          WalletModel walletFromUserAuthenticathed = snapshot.data![1];
          double totalPrice = widget.selectedProduct.price +
            widget.newTransactionModel.fees.fold(0, (sum, fee) => sum + fee.amount);
          return Scaffold(
            appBar: AppBar(
              title: const Text("Método de pago"),
            ),
            body: Column(
              children: [
                Container(
                  //margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      /* const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "¿Cuándo quieres pagar?",
                          style: TextStyle(
                            fontSize: 17
                          ),
                        )
                      ), */
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.wallet),
                          const SizedBox(width: 8), // Espaciado entre icono y texto
                          const Text("Pagar con el monedero"),
                          const Spacer(),
                          Radio(
                            activeColor: Colors.blueAccent,
                            value: options[0],
                            groupValue: currentOption,
                            onChanged: (value) {
                              setState(() {
                                currentOption = value.toString();
                              });
                              widget.newTransactionModel.payMethod = PayMethod.WALLET;
                            },
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 30),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 8), // Espaciado entre icono y texto
                                Flexible(
                                  child: Text(
                                    "El producto se reservará",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 8), // Espaciado entre icono y texto
                                Flexible(
                                  child: Text(
                                    "Pagarás con el dinero disponible del monedero cuando hayas confirmado la recepción del producto",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //todo
                const SizedBox(height: 20), // Espaciado entre las opciones
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.credit_score),
                          const SizedBox(width: 8), // Espaciado entre icono y texto
                          const Text("Pagar con tarjeta"),
                          const SizedBox(width: 142),
                          Radio(
                            activeColor: Colors.blueAccent,
                            value: options[1],
                            groupValue: currentOption,
                            onChanged: (value) {
                              setState(() {
                                currentOption = value.toString();
                              });
                              widget.newTransactionModel.payMethod = PayMethod.CARD;
                            },
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 8), // Espaciado entre icono y texto
                                Flexible(
                                  child: Text(
                                    "El producto se reservará",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 8), // Espaciado entre icono y texto
                                Flexible(
                                  child: Text(
                                    "Pagarás con una tarjeta de pago totalmente segura, el dinero se le transferirá al vendedor cuando hayas recibido el producto",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 2),
                      SumaryProductWidget(
                        transactionModel: widget.newTransactionModel, 
                        productModel: widget.selectedProduct
                      ),
                      const SizedBox(height: 2),
                      const Divider(),
                      
                    ],
                  ),
                ),
              ],
            ),
            
            bottomSheet: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  //widget.newTransactionModel.setFees = await FeeService().getFees();
                  //widget.tabController.animateTo(1);
                  if(widget.newTransactionModel.payMethod == PayMethod.CARD){
                    widget.tabController.animateTo(1);
                  }else{
                    if(walletFromUserAuthenticathed.amount < totalPrice){
                       _buildWalletDialog(context, walletFromUserAuthenticathed);
                    }
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }
      }
    );
  }
}
