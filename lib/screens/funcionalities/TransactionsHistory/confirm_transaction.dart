// ignore_for_file: use_build_context_synchronously
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:prime_store/widgets/dialogs/custom_dialogs.dart';
import 'package:prime_store/model/data/fee_model.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/review_model.dart';
import 'package:prime_store/model/data/transaction_fee_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/wallet_model.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/transaction_buyer_provider.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:prime_store/services/fee_service.dart';
import 'package:prime_store/services/product_service.dart';
import 'package:prime_store/services/transaction_fee_service.dart';
import 'package:prime_store/services/transaction_service.dart';
import 'package:prime_store/services/wallet_service.dart';
import 'package:prime_store/styles/widgets_styles.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ConfirmTransaction extends StatefulWidget {
  final TransactionModel transactionModel;
  final ConfettiController confettiController;

  const ConfirmTransaction({
    super.key,
    required this.transactionModel,
    required this.confettiController
  });

  @override
  State<ConfirmTransaction> createState() => _ConfirmTransactionState();
}

class _ConfirmTransactionState extends State<ConfirmTransaction> {
  //late final Future<ProductModel> _productFuture;
  // ignore: unused_field
  late final Future<List<TransactionFeeModel>> _transactionFeeModel;
  //late final Future<List<dynamic>> _futures;
  late final Future<List<dynamic>> _combinedFutures;
  ReviewModel reviewModel = ReviewModel.defaultConstructor();

  //Método que construye un diálogo para valorar al usuario
  Widget buildRatingDialog() {
  return SimpleDialog(
    title: const Center(
      child: Text(
        "Valora al usuario",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    alignment: Alignment.center,
    contentPadding: const EdgeInsets.all(20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          RatingBar.builder(
            initialRating: 0,
            itemCount: 5, //número de iconos
            itemSize: 40.0, //tamaño de los iconos
            glowColor: null,
            maxRating: 5.0, //valoración máxima
            minRating: 0.0, //valoración mínima
            tapOnlyMode: true, //se puede interactuar
            itemBuilder: (context, index) { //se construyen los iconos
              switch (index) {
                case 0:
                  return const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  );
                case 1:
                  return const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  );
                case 2:
                  return const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  );
                case 3:
                  return const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  );
                case 4:
                  return const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                  );
                default:
                  return const Icon(Icons.error);
              }
            },
            onRatingUpdate: (rating) {
              reviewModel.setRate = rating; //se guarda la calificación
            },
          ),
          const SizedBox(height: 24), // Espaciado debajo del RatingBar
          ElevatedButton(
            onPressed: () {
              showDialog( //se muestra el diálogo para dejar un comentario al usuario
                context: context,
                barrierDismissible: false,
                builder:(_) => buildReviewDialog()
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              backgroundColor: Colors.lightBlue[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Siguiente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  //Método que muestra un dialogo para que el usuario deje un comentario al usuario vendedor
  Widget buildReviewDialog(){
    final TextEditingController reviewController = TextEditingController();
    return SimpleDialog(
      title: const Text('Escriba una breve reseña',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
      alignment: Alignment.center,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical:24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      children: [
        TextFormField( //campo de texto para escribir la reseña
          controller: reviewController,
          maxLines: 2,
          maxLength: 60,
          decoration: InputDecoration(
            labelText: "Escribe tu reseña",
            hintText: "Escribir...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            alignLabelWithHint: true
          ),
          validator: (value){ //valida la reseña del usuario
            if(value!.isEmpty){
              return "Debes escribir una reseña al usuario";
            }else if(value.length < 4){
              return "Mínimo 4 carácteres";
            }
            return null;
          },
        ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async{
              // Registrar la calificación y reseña
              reviewModel.setComment  = reviewController.text.toString();
              widget.transactionModel.setReviewModel = reviewModel;
              widget.transactionModel.transactionState = TransactionState.COMPLETED;
              try{
                await TransactionService().updateTransaction(widget.transactionModel);
                await Provider.of<TransactionBuyerProvider>(context, listen: false)
                  .updateTransactionState(widget.transactionModel.id, TransactionState.COMPLETED);
                ProductModel productModel = await Provider.of<ProductListProvider>(context, listen: false)
                  .getProductById(widget.transactionModel.id);
                WalletModel sellerWalletModel = await WalletService().getWalletByUserId(widget.transactionModel.sellerId);
                await Provider.of<WalletProvider>(context, listen: false)
                  .updateAmountByWalletId(productModel.price, sellerWalletModel.id);
                widget.confettiController.play();
                await showDialog(
                  context: context, 
                  //muestra un diálogo de success si se ha podido registrar la valoración correctamente
                  builder: (_) => buildCustomSuccessDialog(context, "Valoración registrada", 3)
                );
              }on DioException{
                //Diálogo de error si no se puede registar la reseña
                await showDialog(
                  context: context, 
                  builder: (_) => buildCustomErrorDialog(
                    context, 
                    "Error", 
                    "Ha ocurrido un problema al intentar registrar tu valoración", 
                    3
                  )
                );
              }
            },
            style: elevatedButtonStyle,
            child: const Text(
              'Confirmar calificación',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }

  @override
  void initState(){
    super.initState();
    _combinedFutures = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    // Obtener el producto
    final productFuture = ProductService().getProductById(widget.transactionModel.productId);

    // Obtener TransactionFees
    final transactionFeesFuture = TransactionFeeService().getTransactionFeeModelByTransactionId(widget.transactionModel.id);

    // Esperar a ambos resultados
    final results = await Future.wait([productFuture, transactionFeesFuture]);
    final ProductModel product = results[0] as ProductModel;
    final List<TransactionFeeModel> transactionFees = results[1] as List<TransactionFeeModel>;

    // Realizar la segunda petición para obtener los FeeModel
    final feeFutures = transactionFees.map((transactionFee) {
      return FeeService().getFeeById(transactionFee.feeId);
    }).toList();

    // Esperar a todas las solicitudes de FeeModel
    final feeModels = await Future.wait(feeFutures);

    // Retornar todos los datos como una lista
    return [product, feeModels];
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _combinedFutures,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: Colors.lightBlue));
        }else if (snapshot.hasError){
          return Center(child: Text('Error: ${snapshot.error}'));
        }else if(!snapshot.hasData){
          return const Center(child: Text('Producto no encontrado'));
        }else{
          final ProductModel productModel = snapshot.data![0];
          final List<FeeModel> feeModels = snapshot.data![1];
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back)
              )
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                child: Image.network( //imagen del producto
                                  productModel.images[0]!,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) { //icono en caso de error
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
                                      productModel.name, //nombre del producto
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${productModel.price.toStringAsFixed(2)}€", //precio del producto
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
                            children: feeModels.map((fee) {
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
                                "${widget.transactionModel.totalPrice.toStringAsFixed(2)}€",
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
                    ElevatedButton(
                      onPressed:() async{
                        if(mounted) {
                          widget.confettiController.play();
                          await showDialog(
                            context: context, 
                            builder: (_) => buildRatingDialog(),
                            barrierDismissible: false
                          );
                          Navigator.pop(context);
                        }
                      }, 
                      style: elevatedButtonStyle,
                      child: const Text(
                        'Confirmar la entrega',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      }
    );
  }
}