import 'package:flutter/material.dart';

//Actualmente no se utiliza porque ha sido remplazado por el FloatingSearchBar
class CustomSearchBar extends StatelessWidget {
  final SearchController searchController;
  final List<String>? recentSearches;

  const CustomSearchBar({
    super.key,
    required this.searchController,
    required this.recentSearches,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor( //esto estaba envuelto en un padding de 12/5
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
          leading: const Icon(Icons.search),
          hintText: "Buscar...",
          trailing: [
            // Añade una "X" para borrar el texto
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.text = ''; // Limpia el texto del SearchBar
              },
            ),
          ],
        );
      },
      // Búsquedas recientes o sugerencias
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        // Comprueba si hay búsquedas recientes
        if (recentSearches == null || recentSearches!.isEmpty) {
          return [
            const ListTile(
              title: Text(
                'No hay búsquedas recientes',
                textAlign: TextAlign.center,
              ),
            ),
          ];
        } else {
          return [
            const ListTile(
              title: Text(
                'Búsquedas recientes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...recentSearches!.map((String item) {
              return Container(
                padding: const EdgeInsets.fromLTRB(12,10,12,4),
                child: InkWell(
                  child: Column(
                    children: [
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.access_time),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(item),
                          ),
                          const Icon(Icons.arrow_outward)
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ];
        }
      },
    );
  }
}
