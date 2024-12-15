// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/transaction_global_provider.dart';
import 'package:prime_store/screens/funcionalities/ProductDetailsOverview/product_details_overview_screen.dart';
import 'package:prime_store/widgets/productsOverview/components/image_widget.dart';
import 'package:prime_store/widgets/productsOverview/components/product_info_widget.dart';
import 'package:provider/provider.dart';

class UserProductsTab extends StatefulWidget {
  final int userId;
  const UserProductsTab({
    super.key,
    required this.userId
  });

  @override
  State<UserProductsTab> createState() => _UserProductsTabState();
}

class _UserProductsTabState extends State<UserProductsTab> {
  List<ProductModel> productModelList = [];
  List<TransactionModel> transactionList = [];

  Future<void>_fechData() async{
    transactionList = await Provider.of<TransactionGlobalProvider>(context, listen: false).retrieveGlobalTransactionsList();
    productModelList = await Provider.of<ProductListProvider>(context, listen: false)
      .retrieveUserProductsOnSale(widget.userId);
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
          return Consumer2<ProductListProvider,TransactionGlobalProvider>(
            builder: (context, productProvider,transactionGlobalProvider, child) {
              Set<int> soldProductsId = transactionGlobalProvider.transactionGlobalList
                .where((transaction) => transaction.transactionState == TransactionState.COMPLETED)
                .map((transaction) => transaction.productId)
                .toSet();
              List<ProductModel>productListWithoutSoldProducts = productProvider.getUserProductOnSaleList.where((product){
                return !soldProductsId.contains(product.id);
              }).toList();
              return Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (145 / 195),
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: productListWithoutSoldProducts.length,
                  itemBuilder: (context, index) {
                    ProductModel productModel = productListWithoutSoldProducts[index];
                    bool isBooked = transactionGlobalProvider.transactionGlobalList.any((transactionModel) => transactionModel.productId == productModel.id);

                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  ).then((updatedProduct){
                                    if(updatedProduct != null){
                                      setState(() {
                                        productModel = updatedProduct;
                                      });
                                    }
                                  });
                                },
                                child: ImageWidget(productModel: productModel),
                              ),
                              ProductInfoWidget(
                                productModel: productModel,
                              ),
                            ],
                          ),
                        ),
                        !isBooked
                          ? const SizedBox()
                          : Positioned(
                          top: 9,
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