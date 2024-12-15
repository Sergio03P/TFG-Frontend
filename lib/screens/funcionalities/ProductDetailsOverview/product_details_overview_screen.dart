// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prime_store/widgets/dialogs/custom_dialogs.dart';
import 'package:prime_store/model/data/product_model.dart';
import 'package:prime_store/model/data/transaction_model.dart';
import 'package:prime_store/model/data/user_model.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/transaction_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/screens/funcionalities/buyProduct/buy_product_screen.dart';
import 'package:prime_store/screens/funcionalities/editProduct/edit_product_screen.dart';
import 'package:prime_store/screens/funcionalities/userProfile/user_profile_screen.dart';
import 'package:prime_store/services/chat_service.dart';
import 'package:prime_store/services/transaction_service.dart';
import 'package:prime_store/services/user_service.dart';
import 'package:prime_store/styles/widgets_styles.dart';
import 'package:provider/provider.dart';

//Clase que muestra los detalles del producto
class ProductDetailsScreen extends StatefulWidget {
  final int seledtedProductId; //identificador del producto seleccionado

  const ProductDetailsScreen({
    super.key, 
    required this.seledtedProductId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  UserService userService = UserService(); //Servidor del usuario
  GoogleMapController? _mapController; //controlador del fragmento de mapa de google Maps
  LatLng _initialPosition = const LatLng(40.4168, -3.7038); //latitud y longitud inicial
  Circle? _locationCircle; //rango circular de la posición del usuario

  //Método asíncrono que obtiene los datos necesarios de la BBDD
  Future<List<dynamic>> fechData() async{
    ProductModel selectedProduct = await Provider.of<ProductListProvider>(context, listen:false)
      .getProductById(widget.seledtedProductId);
    UserModel ownerUser = await UserService().getUserById(selectedProduct.ownerUserId);
    int userAuthenticatedId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId!;
    TransactionModel? transaction = await TransactionService().getTransactionByProductId(selectedProduct.id);
    List<TransactionModel> ownerTransactionList = await TransactionService().getAllTransactionsFromUserId(selectedProduct.ownerUserId);
    await _setLocationFromPostalCode(ownerUser.postalCode.toString()); //carga la localización del usuario
    return [ownerUser, selectedProduct,userAuthenticatedId,transaction, ownerTransactionList];
  }

  //Método para redondear las valoraciones a multiplos de 2
  double roundUserRating(double rate){
    return (rate * 2).round() / 2;
  }

  //Método para insertar la localización del mapa a la posición del usuario según su código postal
  Future<void> _setLocationFromPostalCode(String postalCode) async {
    try {
      //Método que obtiene la localización a través de la direción del código postal
      List<Location> locations = await locationFromAddress(postalCode);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final LatLng position = LatLng(location.latitude, location.longitude);

        // Configura el estado con la nueva ubicación y el círculo
          _initialPosition = position;
          _locationCircle = Circle( //creamos el rango de la posición del usuario
            circleId: const CircleId("product_location"),
            center: position,
            radius: 500, //radio
            strokeColor: Colors.blueAccent, //color del borde
            strokeWidth: 2,
            fillColor: Colors.blueAccent.withOpacity(0.3), //color interior
          );

        // Mueve la cámara a la nueva posición en el mapa
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(position, 15),
        );
      } else {
        //No se encontraron ubicaciones para el código postal
      }
    } catch (e) {
     //"Error al obtener la ubicación
    }
  }

  //Método construye un alert dialog para eliminar el producto 
  void buildDeleteDialog(){
    showDialog(
      context: context,
      barrierDismissible: false, //lo convierte en modal
      builder: (_) => AlertDialog(
        title: const Text("¿Desea eliminar el producto?"),
        actions: [
          TextButton(
            onPressed:() async{
              try{
                TransactionModel? transaction = await Provider.of<TransactionProvider>(context, listen: false)
                  .getTransactionByProductId(widget.seledtedProductId);
                if(transaction != null){ //Si existe un atransacción pendiente no deja eliminar el producto
                  await showDialog(
                    context: context, 
                    builder: (_) => buildCustomInfoDialog(
                      context, 
                      "Eliminación deshabilitada",
                      "No se puede eliminar un producto que esté en proceso de compra por un usuario",
                      2
                    )
                  );
                }else{
                  //Elimina el producto
                  await Provider.of<ProductListProvider>(context,listen: false)
                    .deleteProductById(widget.seledtedProductId);
                  await showDialog(
                    context: context, 
                    builder: (_) => buildSuccessDialog()
                  );
                }
              }on DioException{
                await showDialog(
                  context: context, 
                  builder: (_) => buildErrorDialog() //Muestra error en caso de que no se haya podido eliminar el producto
                );
              }
              Navigator.pop(context);
            },
            child: const Text("ACEPTAR",style: TextStyle(color: Colors.lightBlue, fontSize: 15)),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("CERRAR", style: TextStyle(color: Colors.lightBlue, fontSize: 15)),
          ),
        ],
      )
    );
  }

  //Dialogo de éxito
  Widget buildSuccessDialog() {
    final int? userAuhenticatedId = Provider.of<UserProvider>(context, listen: false).getUserAuthenticatedId;
    return AlertDialog(
      title: const Text("Eliminación realizada"),
      content: Lottie.asset("assets/animations/success.json", repeat: false, height: 120),
      actions: [
        TextButton(
          onPressed: () =>{
            
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => UserProfile(userId: userAuhenticatedId!,fromWhichScreen: "fromDeleteProduct")),
            )
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  //Dialogo de error
  Widget buildErrorDialog(){
    return AlertDialog(
      title: const Text("Error en la eliminación"),
      content: Lottie.asset("assets/animations/error.json", repeat: false, height: 120),
      actions: [
        TextButton(
          onPressed: () =>{
            Navigator.pop(context),
            Navigator.pop(context), 
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //Método que muestra la imagen en pantalla completa
    void showFullScreenImageView(List<String?> images) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(images: images),
        ),
      );
    }
      //Constuye la pantalla según los datos que necesita obtener de la BBDD
      return FutureBuilder(
        future: fechData(),
        builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(body:Center(child: CircularProgressIndicator(color: Colors.blue)));
        }else if (snapshot.hasError){
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}'))) ;
        }else if(!snapshot.hasData){
          return Scaffold(body:Center(child: Text('No se han podido obtener los datos de la solicitud: ${snapshot.error}')));
        }else{
          UserModel ownerUser = snapshot.data![0];
          ProductModel selectedProduct = snapshot.data![1];
          int userAuthenticatedId = snapshot.data![2];
          TransactionModel? transaction = snapshot.data![3];
          List<TransactionModel> transactionsList = snapshot.data![4];
          
          return Consumer<ProductListProvider>( //consume en tiempo real los datos de la lista de productos
            builder: (context, productListProvider,child){
              //Lista de transacciones donde el usuario es el vendedor
              transactionsList.retainWhere((transaction) => transaction.sellerId == selectedProduct.ownerUserId);
                List<TransactionModel> reviewedTransactions = transactionsList
                  .where((transaction) => transaction.reviewModel != null).toList();
                double averageRating = 0;

                //calcula la media de reseñas
                if (reviewedTransactions.isNotEmpty) {
                  averageRating = reviewedTransactions
                    .map((t) => t.reviewModel!.rate)
                    .reduce((a, b) => a + b) /
                    reviewedTransactions.length;
                } else {
                  averageRating = 0;
                }
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Detalles del Producto",
                      style: TextStyle(color: Colors.black)),
                  leading: IconButton(
                    onPressed: (){
                      Navigator.pop(context, selectedProduct);
                    }, 
                    icon: const Icon(Icons.arrow_back)
                  ),
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.black),
                  elevation: 0,
                ),
                body: SingleChildScrollView( //Permite hacer scrollo verticalmente
                  child: Column(
                    children: [
                      // Carrusel de imágenes del producto
                      CarouselSlider(
                        items: selectedProduct.images
                            .map((image) => GestureDetector(
                                  onTap: () =>
                                      //muetsra los productos en pantalla completa
                                      showFullScreenImageView(selectedProduct.images),
                                  child: Image.network(
                                    image ??
                                        '', // Evita errores si alguna imagen es null
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
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace){
                                      return const Icon(Icons.broken_image, size: 100);
                                    } 
                                  ),
                                ))
                            .toList(),
                        options: CarouselOptions(
                          height: 300,
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {},
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          selectedProduct.images.length,
                          (index) => Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey, // Cambia de color según el índice
                            ),
                          ),
                        ),
                      ),
                      //* Encabezado con información del vendedor y botones de acción
                      Padding(
                        padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector( //Detecta los toques en la pantalla
                                  onTap: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => UserProfile(
                                      userId: selectedProduct.ownerUserId, fromWhichScreen: "fromProductDetails"
                                    )
                                  )),
                                  child: CircleAvatar( //avatar circular con la imagen de perfil del usuario
                                    radius: 24,
                                    backgroundImage: ownerUser.profilePicture != null
                                      ? NetworkImage(ownerUser.profilePicture!)
                                      : null,
                                    child: ownerUser.profilePicture == null
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ownerUser.username,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Icon( //icono de estrella de las valoraciones
                                          Icons.star,
                                          color: roundUserRating(averageRating) > 0
                                            ? Colors.orange
                                            : Colors.grey,
                                          size: 16),
                                        const SizedBox(width: 4),
                                        Text('${roundUserRating(averageRating)} (${reviewedTransactions.length})',
                                            style: TextStyle(color: Colors.grey[600])), // Calificación (ejemplo)
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              //Si el usuaario que ha accedido a los detalles del producto es el propietario,
                              //se habilitan las opciones de editar y eliminar productos
                              children: selectedProduct.ownerUserId == userAuthenticatedId
                                  ? [
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async{
                                              TransactionModel? transaction = await Provider.of<TransactionProvider>(context, listen: false)
                                                .getTransactionByProductId(widget.seledtedProductId);
                                              if(transaction != null){
                                                await showDialog(
                                                  context: context, 
                                                  builder: (_) => buildCustomInfoDialog(
                                                    context, 
                                                    "Edición deshabilitada", 
                                                    "No se puede editar un producto que esté en proceso de compra por un usuario", 
                                                    1
                                                  )
                                                );
                                              }else{
                                                ProductModel auxProduct = selectedProduct.clone();
                                                Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => EditProductScreen(selectedProduct: auxProduct)
                                                )).then((updatedProduct){
                                                  if(updatedProduct != null){
                                                    setState(() {
                                                      selectedProduct = updatedProduct;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              side: const BorderSide(color: Colors.lightBlue),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min, // Para que el botón se ajuste al tamaño del contenido
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.lightBlue,
                                                ),
                                                SizedBox(width: 8), // Espaciado entre el icono y el texto
                                                Text(
                                                  "Editar",
                                                  style: TextStyle(color: Colors.lightBlue),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.red),
                                              color: Colors.white
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                buildDeleteDialog();
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.red,)
                                            ),
                                          )
                                        ],
                                      )
                                    ]
                                  : [
                                      ElevatedButton(
                                        onPressed: () {
                                          UserModel? userAuthenticated = Provider.of<UserProvider>(context,listen: false).getUserAuthenticated;
                                          String authenticathedUsername = userAuthenticated!.username;
                                          
                                          ChatService chatService = ChatService();
                                          chatService.startChat( authenticathedUsername, ownerUser.username, context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.green),
                                        ),
                                        child: const Text("Chat",
                                            style: TextStyle(color: Colors.green)),
                                      ),
                                    ]
                            ),
                          ],
                        ),
                      ),
              
                      //todo  Detalles del producto cortos
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            Text(
                              '${selectedProduct.price.toString()} €',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              selectedProduct.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            //todo fin detalles cortos
                            Text(
                              selectedProduct.description,
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 10),
                            const Text("Ubicación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15,),
                            Container(
                              height: 200, // Altura del mapa
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap( //mapa de GoogleMap
                                  initialCameraPosition: CameraPosition(
                                      target: _initialPosition, zoom: 14),
                                  circles:
                                      _locationCircle != null ? {_locationCircle!} : {},
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                  },
                                  
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botón para contactar al vendedor
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton.icon(
                            style: elevatedButtonStyle,
                            onPressed: transaction == null
                              ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => BuyProductScreen(selectedProduct: selectedProduct)))
                              : (){ //si existe una transacción no deja comprar el producto
                                UserModel? userAuthenticated = Provider.of<UserProvider>(context,listen: false).getUserAuthenticated;
                                String authenticathedUsername = userAuthenticated!.username;
                                String ownerUsername = ownerUser.username;
                                ChatService chatService = ChatService();
                                chatService.startChat( authenticathedUsername, ownerUsername, context);
                              },
                            
                            icon: transaction == null
                              ? null
                              : const Icon(Icons.chat, color: Colors.white),
                            label: transaction == null
                              ? const Text("Comprar", style: TextStyle(fontSize: 16, color: Colors.white))
                              : const Text("Contactar", style: TextStyle(fontSize: 16, color: Colors.white))
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
              
                      //? MAPA
                    ],
                  ),
                ),
              );
            }
          );
        }
      });  
    }
  }

// Método para mostrar las imágenes en pantalla completa
class FullScreenImageView extends StatelessWidget {
  final List<String?> images;

  const FullScreenImageView({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: images[index] != null
                ? Image.network(
                    images[index]!, 
                    fit: BoxFit.contain,
                    //Muestra un barra de carga hasta que se cargue la imagen completamente
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
                : Image.asset("images/damagedFileWithoutbackground.png", fit: BoxFit.contain,)
            ),
          );
        },
      ),
    );
  }
}
