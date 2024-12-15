// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/wallet_model.dart';
import 'package:prime_store/providers/transaction_global_provider.dart';
import 'package:prime_store/providers/transaction_provider.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:prime_store/services/stripe_service.dart';
import 'package:provider/provider.dart';

//Clase en la que aparece el resumén del precio y se confirma la compra
class OrderSummaryTab extends StatefulWidget {
  final TabController tabcontroller;
  final TransactionModel newTransactionModel;
  final ProductModel selectedProduct;

  //Condtructor
  const OrderSummaryTab({
    super.key,
    required this.tabcontroller,
    required this.newTransactionModel,
    required this.selectedProduct
  });

  @override
  State<OrderSummaryTab> createState() => _OrderSummaryTabState();
}

class _OrderSummaryTabState extends State<OrderSummaryTab> {

  @override
  Widget build(BuildContext context) {
    // Calcula el total sumando el precio del producto y las tasas
    double totalPrice = widget.selectedProduct.price +
        widget.newTransactionModel.fees.fold(0, (sum, fee) => sum + fee.amount);

    //Método que maneja el pago con el monedero de la app
    void handleWalletPayment() async{
      widget.newTransactionModel.setTotalPrice = double.parse(totalPrice.toStringAsFixed(2)); // todo
      await Provider.of<TransactionProvider>(context, listen: false).addTransaction(widget.newTransactionModel);
      WalletModel walletModel = Provider.of<WalletProvider>(context, listen: false).getWalletModel;
      await Provider.of<WalletProvider>(context, listen: false)
        .updateAmountByWalletId(-(double.parse(totalPrice.toStringAsFixed(2))), walletModel.id);
      await Navigator.pushReplacementNamed(context, "/home");
    }

    //Método que maneja el pago con tarjeta
    void handleCardPayment() async{
      widget.newTransactionModel.setTotalPrice = double.parse(totalPrice.toStringAsFixed(2));
      bool isPaymentSuccess = await StripeService.instance.makePayment(double.parse(totalPrice.toStringAsFixed(2)));
      if(isPaymentSuccess){
        await Provider.of<TransactionGlobalProvider>(context, listen: false).addTransaction(widget.newTransactionModel);
        await Navigator.pushReplacementNamed(context, "/home");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resumen de tu compra"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contenedor superior para el resumen del producto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          widget.selectedProduct.images[0]!,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 32, color: Colors.grey);
                          },
                        )
                      ),
                      const SizedBox(width: 12),
                      // Nombre y precio del producto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedProduct.name, //nombre del producto
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.selectedProduct.price.toStringAsFixed(2)}€",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Lista de tasas dinámicas
                  Column(
                    children: widget.newTransactionModel.fees.map((fee) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fee.name,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              "${(fee.amount).toStringAsFixed(2)}€",
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${totalPrice.toStringAsFixed(2)}€",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton( // Botón de compra
              onPressed: () {
                widget.newTransactionModel.payMethod == PayMethod.WALLET
                  ? handleWalletPayment()
                  : handleCardPayment();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.teal, // Color del botón
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
