import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/review_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/services/product_service.dart';
import 'package:prime_store/services/user_service.dart';

class UserReviewTab extends StatefulWidget {
  final TabController tabController;
  final List<ProductModel> productModelList;
  final List<TransactionModel> transactionList;

  const UserReviewTab({
    super.key,
    required this.tabController,
    required this.productModelList,
    required this.transactionList
  });

  @override
  State<UserReviewTab> createState() => _UserReviewTabState();
}

class _UserReviewTabState extends State<UserReviewTab> {
  Future<List<dynamic>> fechData(TransactionModel transactionModel) async{
    UserModel userFromReview = await UserService().getUserById(transactionModel.buyerId);
    ProductModel productFromTransaction = await ProductService().getProductById(transactionModel.productId);
    return [userFromReview, productFromTransaction];
  }

  @override
  Widget build(BuildContext context) {
    final List<TransactionModel> reviewedTransactions = widget.transactionList
        .where((transaction) => transaction.reviewModel != null)
        .toList();
    final int reviewsCount = widget.transactionList.where((transaction) => transaction.reviewModel != null).toList().length;
    return reviewsCount == 0
      ? const Center(
          child: Text(
            "No existen valoraciones todavía",
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey
            )
          )
        ) 
      : Expanded(
      child: ListView.builder(
        itemCount: reviewedTransactions.length,
        itemBuilder: (context, index){
          final transaction = reviewedTransactions[index];
          final ReviewModel review = transaction.reviewModel!;
          return FutureBuilder<List<dynamic>>(
            future: fechData(transaction), 
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child:CircularProgressIndicator(color: Colors.lightBlue));// Mostrar indicador de carga
              } else if (snapshot.hasError) {
                return const Center(child:Text('Error al cargar el usuario'));// Mostrar error
              } else if (!snapshot.hasData) {
                return const Center(child:Text('Usuario no encontrado')); // Mostrar mensaje si no hay datos
              }else{
                final UserModel userFromReview = snapshot.data![0];
                final ProductModel productFromTransaction = snapshot.data![1];
                return ListTile(
                  leading: SizedBox( //esto está para evitar un error donde el stack consume todo el ListTile
                    width: 60,
                    height: 60,
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 20, bottom: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              productFromTransaction.images[0]!,
                              loadingBuilder: (context, child, loadingProgress) {
                                if(loadingProgress == null){
                                  return child;
                                }else{
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                      color: Colors.lightBlue,
                                    ),
                                  );
                                }
                              },
                            )
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 16,
                          child: CircleAvatar(
                            radius: 17,
                            backgroundImage: userFromReview.profilePicture != null
                              ? NetworkImage(userFromReview.profilePicture!)
                              : null,
                            child: userFromReview.profilePicture == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                          )
                        ) 
                      ],
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        productFromTransaction.category,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      RatingBar.builder(
                        initialRating: review.rate.toDouble(),
                        ignoreGestures: true,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 16.0,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.comment, style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Text('Por ', style: TextStyle(color: Colors.grey[700]!.withOpacity(0.9))),
                          Text(
                            userFromReview.username, 
                            style: TextStyle(
                              color: Colors.grey[900]!.withOpacity(0.7), fontWeight: FontWeight.bold
                            )
                          )
                        ],
                      )
                    ],
                  ),
                  isThreeLine: true,
                );
              }
            }
          );
        },
      ),
    );
  }
}