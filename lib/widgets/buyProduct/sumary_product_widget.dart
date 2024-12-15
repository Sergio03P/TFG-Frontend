import 'package:flutter/material.dart';
import 'package:prime_store/model/data/fee_model.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';

class SumaryProductWidget extends StatelessWidget {
  final TransactionModel transactionModel;
  final ProductModel productModel;

  const SumaryProductWidget({
    super.key,
    required this.transactionModel,
    required this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    List<FeeModel> feeList = transactionModel.getFees;
    double totalPrice = productModel.price +
        feeList.fold(0, (sum, fee) => sum + fee.amount);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              productModel.images[0]!, // Primera imagen del producto
              fit: BoxFit.cover, // Imagen se adapta proporcionalmente
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(width: 12), // Separación entre imagen y contenido
          // Contenedor flexible de textos
          Expanded( // Proporción para el texto (7/10 del espacio total)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del producto y precio
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productModel.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis, // Truncar si es largo
                        ),
                      ),
                      Text(
                        '${productModel.price.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4), // Separación entre líneas
                // Lista de comisiones
                ...feeList.map((fee) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fee.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          '${fee.amount.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(), // Línea divisoria
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalPrice.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}