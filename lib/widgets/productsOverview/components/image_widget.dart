import 'package:flutter/material.dart';
import 'package:prime_store/model/data/product_model.dart';

class ImageWidget extends StatelessWidget {
  final ProductModel productModel;

  const ImageWidget({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: productModel.images.isNotEmpty &&
              productModel.images.where((image) => image != null).isNotEmpty
          ? FadeInImage.assetNetwork(
              placeholder: 'images/loading_v1.gif',
              placeholderCacheWidth: 120,
              placeholderCacheHeight: 120,
              placeholderFit: BoxFit.scaleDown,
              imageCacheWidth: 120,
              imageCacheHeight: 120,
              image: productModel.images.firstWhere((image) => image != null)!,
              fit: BoxFit.fill,
              width: 130,
              height: 135,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'images/damagedFile.jpg',
                  fit: BoxFit.contain,
                  width: 120,
                  height: 120,
                );
              },
            )
          : Image.asset(
              'images/eyes4.jpg', // Imagen predeterminada si no hay imágenes
              fit: BoxFit.contain,
              width: 120,
              height: 120,
            ),
    );
  }
}