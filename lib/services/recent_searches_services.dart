import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesService {
  static const String _keyRecentSearches = 'recent_searches';

  //cargar las búsquedas recientes desde SharedPreferences
  Future<List<String>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_keyRecentSearches) ?? [];
    return recentSearches;
  }

  //guardar las búsquedas recientes en SharedPreferences
  static Future<void> _saveRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, searches);
  }

  //añadir una nueva búsqueda a la lista (sin duplicados y con un máximo de elementos)
  Future<List<String>> addSearch(String searchQuery) async {
    final currentSearches = await loadRecentSearches();

    //Si la búsqueda ya existe, la eliminamos para moverla al principio
    currentSearches.remove(searchQuery);

    //añadir la búsqueda al principio
    currentSearches.insert(0, searchQuery);

    //limitar el tamaño de la lista a un máximo (por ejemplo, 10 búsquedas)
    if (currentSearches.length > 5) {
      currentSearches.removeLast();
    }

    //guardar la lista actualizada
    await _saveRecentSearches(currentSearches);
    return currentSearches;
  }
}
