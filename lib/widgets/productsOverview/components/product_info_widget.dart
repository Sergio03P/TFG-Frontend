import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';

class ProductInfoWidget extends StatelessWidget {
  final ProductModel productModel;
  final bool? isFavourite; 
  final VoidCallback? onFavouriteToggle;

  const ProductInfoWidget({
    super.key,
    required this.productModel,
    this.isFavourite, 
    this.onFavouriteToggle, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 4, 13, 10), //todo aqui se ajusta el espacio del contenido
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${productModel.price.toString()}€',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                // Mostrar el icono solo si isFavourite no es null
                if (isFavourite != null && onFavouriteToggle != null)
                  InkWell(
                    onTap: onFavouriteToggle,
                    child: Icon(
                      isFavourite! ? Icons.favorite : Icons.favorite_border,
                      color: isFavourite! ? Colors.red : null,
                    ),
                  ),
              ],
            ),
            Text(
              productModel.name,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}