import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:todo_app/repositories/constants.dart';

class ImageUpload {
  final ImageSource source;
  final int quality;

  ImageUpload(this.source, {this.quality = 50});

  Future<File> getImageFromDevice() async {
    final imageFile = await ImagePicker().getImage(source: source);
    if (imageFile == null) {
      return null;
    }
    // 画像を圧縮
    final File compressedFile = File(imageFile.path);
    return compressedFile;
  }
}

class ImageToAPI {
  Future<String> upload(File imageFile) async {
    var dio = Dio();
    FormData formData = FormData.fromMap(
        {"file": await MultipartFile.fromFile(imageFile.path)});
    Response<dynamic> response = await dio.post("$kImageUrl", data: formData);
    final String imgurl = response.data;
    return imgurl;
  }
}

class DeleteImage {
  Future<void> delete(String fileName) async {
    final response = await http.delete("$kImageUrl/$fileName");
    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}
