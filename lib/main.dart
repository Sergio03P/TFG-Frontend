//import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:prime_store/keys/keys.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/providers/favourite_product_list_provider.dart';
import 'package:prime_store/providers/product_list_provider.dart';
import 'package:prime_store/providers/recent_search_provider.dart';
import 'package:prime_store/providers/side_menu_provider.dart';
import 'package:prime_store/providers/transaction_buyer_provider.dart';
import 'package:prime_store/providers/transaction_global_provider.dart';
import 'package:prime_store/providers/transaction_provider.dart';
import 'package:prime_store/providers/transaction_seller_provider.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:prime_store/screens/entry_point.dart';
import 'package:prime_store/screens/registration/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/date_symbol_data_local.dart' ;

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings estén inicializados antes de async code
  SystemChrome.setPreferredOrientations([ //Bloquea la orientación de la pantalla en vertical
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Stripe.publishableKey = ApiKeys.publishableStripeApiKey;
  await initializeDateFormatting('es', null);
  final client  = StreamChatClient(ApiKeys.streamExampleApiKey, logLevel: Level.INFO);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductListProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SideMenuProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProductListProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => TransactionSellerProvider()),
        ChangeNotifierProvider(create: (_) => TransactionBuyerProvider()),
        ChangeNotifierProvider(create: (_) => TransactionGlobalProvider()),
        ChangeNotifierProvider(create: (_) => RecentSearchProvider()),
        ChangeNotifierProvider(create: (_) => BottomIndexNavigationProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        Provider<StreamChatClient>.value(value: client)
      ],
      child: const MainApp())
  );
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    final client  = Provider.of<StreamChatClient>(context, listen: false);

    return MaterialApp(
      builder: (context, widget){
        return StreamChat(
          client: client,
          child: widget
        );
      },
      title: 'Prime Store app testing',
      debugShowCheckedModeBanner: false, //Quita la marca de agua de debug mode
      initialRoute: "/",
      routes: {
        "/": (context) => const AuthScreen(),
        "/home": (context) => const EntryPoint(),
      },
    );
  }
}
