// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/providers/favourite_product_list_provider.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/transaction_global_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/ProductDetailsOverview/product_details_overview_screen.dart';
import 'package:prime_store/widgets/productsOverview/components/image_widget.dart';
import 'package:prime_store/widgets/productsOverview/components/product_info_widget.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({
    super.key,
  });

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  List<ProductModel> productModelList = [];
  List<TransactionModel> transactionList = [];

  Future<void>_fechData() async{
    transactionList = await Provider.of<TransactionGlobalProvider>(context, listen: false).retrieveGlobalTransactionsList();
    final int userAuthenticatedId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId!;
    productModelList = await Provider.of<ProductListProvider>(context, listen: false)
      .retrieveProductsOnSale(userAuthenticatedId);
    Provider.of<FavouriteProductListProvider>(context, listen: false).getFavouriteProducts(userAuthenticatedId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fechData(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }else if (snapshot.hasError){
          return Center(child: Text('Error: ${snapshot.error}'));
        }else{
          return Consumer3<ProductListProvider, FavouriteProductListProvider,TransactionGlobalProvider>(
            builder: (context, productProvider, favouriteProvider,transactionGlobalProvider, child) {
              Set<int> soldProductsId = transactionGlobalProvider.transactionGlobalList
                .where((transaction) => transaction.transactionState == TransactionState.COMPLETED)
                .map((transaction) => transaction.productId)
                .toSet();
              List<ProductModel>productListWithoutSoldProducts = productProvider.getProductOnSaleList.where((product){
                return !soldProductsId.contains(product.id);
              }).toList();
              return productListWithoutSoldProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No hay productos en venta actualmente :(", 
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    )
                  )
                :Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: (145 / 195),
                    ),
                    scrollDirection: Axis.vertical,
                    itemCount: productListWithoutSoldProducts.length, 
                    itemBuilder: (context, index) {
                      final ProductModel productModel = productListWithoutSoldProducts[index];
                      final isFavourite = favouriteProvider.getFavouriteProductList
                          .any((favouriteProduct) => favouriteProduct.id == productModel.id);
                      bool isBooked = transactionGlobalProvider.transactionGlobalList.any((transactionModel) => transactionModel.productId == productModel.id);

                      return Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white, 
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailsScreen(
                                          seledtedProductId: productModel.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ImageWidget(productModel: productModel),
                                ),
                                ProductInfoWidget(
                                  productModel: productModel,
                                  isFavourite: isFavourite,
                                  onFavouriteToggle: () async {
                                    final userModel = Provider.of<UserProvider>(context, listen: false).getUserAuthenticated;
                                    if (userModel != null) {
                                      if (isFavourite) {
                                        await favouriteProvider.removeFavouriteProduct(userModel.id, productModel.id);
                                      } else {
                                        await favouriteProvider.addFavouriteProduct(userModel.id, productModel.id);
                                      }
                                    }
                                  },    
                                ),
                              ],
                            ),
                          ),
                          !isBooked
                            ? const SizedBox()
                            : Positioned(
                              top: 12,
                              left: 16,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.bookmark_border,
                                  size: 27,
                                  color: Colors.lightBlue[300], 
                                ),
                              ) 
                            )
                        ] 
                      );
                    },
                  ),
                );
              },
          );
        }
      }
    );
  }
}
