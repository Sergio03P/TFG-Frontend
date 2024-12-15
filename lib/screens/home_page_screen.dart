// ignore_for_file: avoid_single_cascade_in_expression_statements, use_build_context_synchronously
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/recent_search_provider.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/addProduct/upload_product.dart';
import 'package:prime_store/screens/funcionalities/chat/chat_list_screen.dart';
import 'package:prime_store/screens/funcionalities/favouriteProducts/favourite_products_list_screen.dart';
import 'package:prime_store/util/category_product_conversor.dart';
import 'package:prime_store/widgets/product_list_widget.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late FloatingSearchBarController searchController;
  //int _currentIndex = 0;
  List<String> recentSearches = [
    'Flutter',
    'Dart',
  ];
  bool showRecentSearches = true;
  bool isKeyBoardVisible = false;
  bool showTitle = false;
  bool isSearchingActive = false;
  bool isLoading = false;

  Map<int, bool> activeCategoryFilters = {};
  int? activeCategoryIndex;
  String? auxQuery;
  List<ProductModel>? auxProductList;

  @override
  void initState() {
    super.initState();
    loadRecentSearches();
    searchController = FloatingSearchBarController();
    activeCategoryIndex = null;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterProducts(String query) async{
    // Evitar realizar filtrado si ya está en proceso
    if (isLoading || query == auxQuery) {
      return;
    }
    setState(() {
      isLoading = true;
      auxQuery = query; // Muestra el botón de "atrás" cuando se inicia una búsqueda
    });

    if (query.isEmpty) {
      // Si no hay búsqueda, restauramos la lista completa
      Provider.of<ProductListProvider>(context, listen: false).getProductOnSaleList;
      setState(() {
        isLoading = false;
      });
      return;
    }

    final searchLower = query.toLowerCase();

    final List<Map<String, dynamic>> productScoreList = Provider.of<ProductListProvider>(context, listen: false).getProductOnSaleList
        .map((product) {
          int relevanceScore = 0;

          final productNameLower = product.name.toLowerCase();
          if (productNameLower.contains(searchLower)) {
            relevanceScore += productNameLower.startsWith(searchLower) ? 10 : 5;
          }

          final productDescriptionLower = product.description.toLowerCase();
          if (productDescriptionLower.contains(searchLower)) {
            relevanceScore += productDescriptionLower.startsWith(searchLower) ? 7 : 3;
          }

          final productCategoryLower = product.category.toLowerCase();
          if (productCategoryLower.contains(searchLower)) {
            relevanceScore += productCategoryLower.startsWith(searchLower) ? 5 : 2;
          }

          return {'product': product, 'relevanceScore': relevanceScore};
        })
        .where((productMap) => (productMap['relevanceScore'] as int) > 0)
        .toList();

    productScoreList.sort((a, b) {
      final scoreA = a['relevanceScore'] as int;
      final scoreB = b['relevanceScore'] as int;
      return scoreB.compareTo(scoreA); // Ordenar de mayor a menor relevancia
    });

    final List<ProductModel> filteredProducts = [];
    // ignore: avoid_function_literals_in_foreach_calls
    productScoreList.forEach((productMap) {
      filteredProducts.add(productMap['product'] as ProductModel);
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    // Actualiza la lista en el Provider
    Provider.of<ProductListProvider>(context, listen: false).setProductOnSaleList = filteredProducts;
    auxProductList = filteredProducts;
    
    setState(() {
      isLoading = false;
      isKeyBoardVisible = false;
    });

    await Provider.of<RecentSearchProvider>(context, listen: false).addRecentSearch(query);
    loadRecentSearches();

    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadRecentSearches() async{
    await Provider.of<RecentSearchProvider>(context, listen: false).retrieveRecentSearches();
    final searches = Provider.of<RecentSearchProvider>(context, listen: false).getRecentSearches;
    setState(() {
      recentSearches = searches;
    });
  }

  void filterWithCategory() {
    final currentProducts = Provider.of<ProductListProvider>(context, listen: false).getProductOnSaleList;
    currentProducts.retainWhere((product){
      final ProductCategoryEnum productCategory = fromModelcategoryConversor(product.category);
      return productCategory == ProductCategoryEnum.values[activeCategoryIndex!];
    });
     Provider.of<ProductListProvider>(context, listen: false).setProductOnSaleList = currentProducts;
  }

  void filterWithCategoryAndSearch(){
    final auxList = auxProductList!.where((product){
      final ProductCategoryEnum productCategory = fromModelcategoryConversor(product.category);
      return productCategory == ProductCategoryEnum.values[activeCategoryIndex!];
    }).toList();
    Provider.of<ProductListProvider>(context, listen: false).setProductOnSaleList = auxList;
  }

  List<String> getFilteredSearches(String query) {
    if (query.isEmpty) {
      return recentSearches;
    } else {
      return recentSearches
          .where((search) =>
              search.toLowerCase().contains(query.toLowerCase()) &&
              search.toLowerCase() != query.toLowerCase())
          .toList();
    }
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.only(top: showTitle ? 50 : 0),
      child: FloatingSearchBar(
        onSubmitted: (query) async{
          int? userAuthenticatedId  = Provider.of<UserProvider>(context,listen: false).getUserAuthenticatedId;
          if(userAuthenticatedId != null){
            await Provider.of<ProductListProvider>(context, listen: false).retrieveProductsOnSale(userAuthenticatedId);
            filterProducts(query);
            setState(() {
              isSearchingActive = true;
              showRecentSearches = false;
            });
          }
          
        },
        controller: searchController,
        hint: 'Buscar...',
        backgroundColor: Colors.grey[50],
        scrollPadding: const EdgeInsets.only(top: 26, bottom: 56),
        transitionDuration: const Duration(milliseconds: 500),
        transitionCurve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0.0 : -1.0,
        openAxisAlignment: 0.0,
        width: isPortrait ? 600 : 500,
        debounceDelay: const Duration(milliseconds: 500),
        clearQueryOnClose: false,
        onQueryChanged: (query) {
          setState(() {
            showRecentSearches = true;
          });
        },
        onFocusChanged: (isFocused) async{
          setState((){
            isKeyBoardVisible = isFocused;
          });
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {
            isSearchingActive = isFocused;
          });
        },
        transition: CircularFloatingSearchBarTransition(),
        leadingActions: [
          isSearchingActive
          ? FloatingSearchBarAction.icon(
            onTap: () {
              int? userAuthenticatedId  = Provider.of<UserProvider>(context,listen: false).getUserAuthenticatedId;
              if(userAuthenticatedId != null){
                Provider.of<ProductListProvider>(context, listen: false).retrieveProductsOnSale(userAuthenticatedId);
                setState(() {
                  isSearchingActive = false;
                  isKeyBoardVisible = false;
                  auxQuery = null;
                  auxProductList = null;
                });
              }
              searchController.clear();
              
            },
            icon: const Icon(Icons.arrow_back),
              showIfClosed: true
              
            )
          : Container()    
        ],
        actions: [
          FloatingSearchBarAction.searchToClear(
            showIfClosed: false,
          ),
        ],
        builder: (context, transition) {
          return showRecentSearches
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white,
                    elevation: 4.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: getFilteredSearches(searchController.query)
                          .map((query) {
                        return ListTile(
                          //dense: true,
                          leading: const Icon(Icons.access_time),
                          title: Text(query),
                          onTap: () {
                            setState(() {
                              showRecentSearches = false;
                            });
                            searchController.query = query;
                          },
                        );
                      }).toList(),
                    ),
                  ),
                )
              : Container();
        },
      ),
    );
  }

  Widget buildCategoryContainer() {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: ProductCategoryEnum.values.length,
        itemBuilder: (BuildContext context, int index) {
          bool isActive = activeCategoryIndex == index;
          return GestureDetector(
            onTap: (){
              setState(() {
                if(activeCategoryIndex == index){
                  activeCategoryIndex = null;
                  if(auxProductList != null) {
                    Provider.of<ProductListProvider>(context, listen: false).setProductOnSaleList = auxProductList!;
                  }else{
                    int? userAuthenticatedId  = Provider.of<UserProvider>(context,listen: false).getUserAuthenticatedId;
                    if(userAuthenticatedId != null){
                      Provider.of<ProductListProvider>(context, listen: false).retrieveProductsOnSale(userAuthenticatedId);
                    }
                  } 
                }else{ //?Si la categoria no está seleccionada
                  activeCategoryIndex = index;
                  if(isSearchingActive){
                    if(auxProductList != null) filterWithCategoryAndSearch();
                  }else{
                    filterWithCategory();
                  }     
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: !isActive ? Colors.lightBlue.withOpacity(0.4) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: !isActive
                  ? null
                  : Border.all(color: Colors.blue)
              ),
              child: Row(
                children: [
                  Center(
                    child: Text(
                      categoryConversor(ProductCategoryEnum.values[index]),
                      style: !isActive
                        ? null
                        : const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(width: 5),
                  !isActive 
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.cancel_outlined, size: 14,
                      )
                ],
              ),
            ),
          );
        },
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sideMenuProvider = Provider.of<SideMenuProvider>(context, listen: false);
    final bottomIndexNavigationProvider = Provider.of<BottomIndexNavigationProvider>(context, listen: true);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: [
                  SizedBox(height: showTitle ? 120 : 70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: buildCategoryContainer(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Consumer<ProductListProvider>(
                        builder: (_, productProvider, __) {
                          return const ProductListWidget(); //Lista de productos
                        },
                      ),
                    ),
                  ),
                  isKeyBoardVisible
                      ? const SizedBox()
                      : CustomNavigationBar(
                          elevation: 9,
                          currentIndex: bottomIndexNavigationProvider.getIndex,
                          onTap: (index) {
                            bottomIndexNavigationProvider.setIndex = index;
                            setState(() {
                              showRecentSearches = true;
                            });
                            if (bottomIndexNavigationProvider.getIndex == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FavouriteProductListScreen()),
                              );
                            } else if (bottomIndexNavigationProvider.getIndex == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const UploadProduct()),
                              );
                            } else if (bottomIndexNavigationProvider.getIndex == 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChatListScreen()),
                              );
                            } else if (bottomIndexNavigationProvider.getIndex == 4) {
                              sideMenuProvider.toggleSideMenu();
                            }
                          },
                          items: [
                            CustomNavigationBarItem(icon: const Icon(Icons.home_outlined)),
                            CustomNavigationBarItem(icon: const Icon(Icons.favorite_outline)),
                            CustomNavigationBarItem(icon: const Icon(Icons.add_circle_outline)),
                            CustomNavigationBarItem(icon: const Icon(Icons.chat),badgeCount: 2, showBadge: false,),
                            CustomNavigationBarItem(icon: const Icon(Icons.person)),
                          ],
                        ),
                ],
              ),
            ),
          ),
          isLoading
              ? Container(
                  color: Colors.black26,
                  child: const Center(
                      child: CircularProgressIndicator(color: Colors.blue)),
                )
              : buildFloatingSearchBar(),
        ],
      ),
    );
  }
}
