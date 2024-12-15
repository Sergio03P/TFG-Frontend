import 'package:prime_store/model/data/product_model.dart';

String categoryConversor(ProductCategoryEnum category){
  if(category == ProductCategoryEnum.COCHES) return 'Coches';
  if(category == ProductCategoryEnum.MOTOS) return 'Motos';
  if(category == ProductCategoryEnum.MODA_Y_ACCESORIOS) return 'Moda y accesorios';
  if(category == ProductCategoryEnum.TECNOLOGIA) return 'Tecnología';
  if(category == ProductCategoryEnum.DEPORTE_Y_OCIO) return 'Deporte y ocio';
  if(category == ProductCategoryEnum.BICICLETAS) return 'Bicicletas';
  if(category == ProductCategoryEnum.HOGAR) return 'Hogar';
  if(category == ProductCategoryEnum.ELECTRODOMESTICO) return 'Electrodoméstico';
  if(category == ProductCategoryEnum.CINE) return 'Cine';
  if(category == ProductCategoryEnum.LIBROS) return 'Libros';
  if(category == ProductCategoryEnum.MUSICA) return 'Musica';
  if(category == ProductCategoryEnum.COLECCIONISMO) return 'Coleccionismo';
  if(category == ProductCategoryEnum.CONSTRUCCION) return 'Construcción';
  if(category == ProductCategoryEnum.OTROS) return 'Otros';
  return '';
}

ProductCategoryEnum fromModelcategoryConversor(String category){
  if(category == 'Coches') return ProductCategoryEnum.COCHES;
  if(category == 'Motos') return ProductCategoryEnum.MOTOS;
  if(category == 'Moda y accesorios') return ProductCategoryEnum.MODA_Y_ACCESORIOS;
  if(category == 'Tecnología') return ProductCategoryEnum.TECNOLOGIA;
  if(category == 'Deporte y ocio') return ProductCategoryEnum.DEPORTE_Y_OCIO;
  if(category == 'Bicicletas') return ProductCategoryEnum.BICICLETAS;
  if(category == 'Hogar') return ProductCategoryEnum.HOGAR;
  if(category == 'Electrodoméstico') return ProductCategoryEnum.ELECTRODOMESTICO;
  if(category == 'Cine') return ProductCategoryEnum.CINE;
  if(category == 'Libros') return ProductCategoryEnum.LIBROS;
  if(category == 'Musica') return ProductCategoryEnum.MUSICA;
  if(category == 'Coleccionismo') return ProductCategoryEnum.COLECCIONISMO;
  if(category == 'Construcción') return ProductCategoryEnum.CONSTRUCCION;
  return ProductCategoryEnum.OTROS;
}

ProductCategoryEnum toProductEnumType(String category){
  if(category == "COCHES") return ProductCategoryEnum.COCHES;
  if(category == "MOTOS") return ProductCategoryEnum.MOTOS;
  if(category == "MODA_Y_ACCESORIOS") return ProductCategoryEnum.MODA_Y_ACCESORIOS;
  if(category == "TECNOLOGIA") return ProductCategoryEnum.TECNOLOGIA;
  if(category == "DEPORTE_Y_OCIO") return ProductCategoryEnum.DEPORTE_Y_OCIO;
  if(category == "BICICLETAS") return ProductCategoryEnum.BICICLETAS;
  if(category == "HOGAR") return ProductCategoryEnum.HOGAR;
  if(category == "ELECTRODOMESTICO") return ProductCategoryEnum.ELECTRODOMESTICO;
  if(category == "CINE") return ProductCategoryEnum.CINE;
  if(category == "LIBROS") return ProductCategoryEnum.LIBROS;
  if(category == "MUSICA") return ProductCategoryEnum.MUSICA;
  if(category == "COLECCIONISMO") return ProductCategoryEnum.COLECCIONISMO;
  if(category == "CONSTRUCCION") return ProductCategoryEnum.CONSTRUCCION;
  return ProductCategoryEnum.OTROS;
}