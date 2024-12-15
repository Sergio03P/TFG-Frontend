import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class CloudinaryService {
  // Función para subir imágenes a cloudinary
  Future<String?> uploadImageToCloudinary(XFile? image) async {
    try{
      final baseURL = Uri.parse('https://api.cloudinary.com/v1_1/di2csvpup/upload');
      File file = File(image!.path);
      
      final request = http.MultipartRequest('POST',baseURL)
        ..fields['upload_preset'] = 'prime_store'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if(response.statusCode == 200){
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url']; //se obtiene la imagen con el protocolo https
      }else{
        return null;
      }
    } catch(e){
      //'Error uploading to cloudinary: $e');
      rethrow;
    }
  }
}
