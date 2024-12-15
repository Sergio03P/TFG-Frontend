// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime_store/providers/user_provider.dart';
import 'package:prime_store/providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      int? userAuthenticatedId =
          Provider.of<UserProvider>(context, listen: false)
              .getUserAuthenticatedId;
      if (userAuthenticatedId != null) {
        await Provider.of<WalletProvider>(context, listen: false)
            .retrieveWallet(userAuthenticatedId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monedero"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightBlue,)) // Muestra el cargando
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saldo del Monedero
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:  [
                        BoxShadow(
                          color: Colors.grey[400]!,
                          offset: const Offset(8, 8),
                          blurRadius: 8,
                        ),
                      ]
                      
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${walletProvider.getWalletModel.amount} €",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Botón Cobrar
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.qr_code_2,
                                      color: Colors.teal),
                                  onPressed: () {
                                  },
                                ),
                                const Text("Cobrar"),
                              ],
                            ),
                            // Botón Pagar
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward,
                                      color: Colors.teal),
                                  onPressed: () {
                                  },
                                ),
                                const Text("Pagar"),
                              ],
                            ),
                            // Botón Retirar
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.account_balance,
                                      color: Colors.teal),
                                  onPressed: () {
                                    
                                  },
                                ),
                                const Text("Retirar"),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Historial de movimientos
                  ListTile(
                    title: const Text("Historial de movimientos"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      
                    },
                  ),
                  const Divider(),
                  // Datos bancarios
                  ListTile(
                    title: const Text("Datos bancarios"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
