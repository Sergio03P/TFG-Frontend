import 'package:flutter/material.dart';
import 'package:prime_store/services/recent_searches_services.dart';

//CLase que maneja el contexto global de las búsquedas recientes
class RecentSearchProvider with ChangeNotifier{
  List<String> recentSearches = []; //lista de las búsquedas recientes
  final _recentSearchesService = RecentSearchesService(); //Servidor de búsquedas recientes

  //Obtener las búsquedas recientes de la BBDD
  Future<void> retrieveRecentSearches() async{
   recentSearches = await _recentSearchesService.loadRecentSearches(); //carga las búsquedas en la lista
   notifyListeners(); //notifica a los oyentes
  }

  //Añade una nueva búesqueda
  Future<void> addRecentSearch(String search) async{
    recentSearches = await _recentSearchesService.addSearch(search); //añade la nueva búsqueda a la BBDD y la lista
    notifyListeners(); //notifica a los oyentes
  }

  //Getter
  get getRecentSearches => recentSearches;
}