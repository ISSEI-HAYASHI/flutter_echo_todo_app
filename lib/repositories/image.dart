import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:http/http.dart' as http;
// import 'package:image/image.dart';
import 'package:todo_app/repositories/constants.dart';

// import 'package:path/path.dart' as p;
// import 'package:async/async.dart';

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
    FormData formData = FormData.fromMap({
      "name": "namecontent",
      "file": await MultipartFile.fromFile(imageFile.path)
    });
    Response<dynamic> response =
        await dio.post("$kImageUploadUrl", data: formData);
    final String imgurl = response.data;
    return imgurl;
  }
}

// class DisplayImage {
//   Future<File> download(String filename) async {
//     var dio = Dio();
//     final response = await dio.get('$kImageDownloadUrl/$filename');
//     print(response.statusCode);
//     print(response.data);
//     print(response.data.runtimeType);
//     // var image = decodeImage(response.data);
//     // print(image);
//     // print(image.runtimeType);
//     File file = response.data;
//     return file;
//   }
// }

// class ImageToAPI {
//   Future<String> upload(File imageFile) async {
//     var uri = Uri.parse('$kImageUploadUrl');
//     var request = http.MultipartRequest("POST", uri);
//     var multipartFile = http.MultipartFile.fromBytes(
//       'image',
//       await imageFile.readAsBytes(),
//       // contentType: kMultipartMime,
//     );
//     request.files.add(multipartFile);
//     var response = await request.send().then((response) {
//       if (response.statusCode == 200) {
//         print("Uploaded!");
//       }
//     });
//     final String imgurl = jsonDecode(response.body.toString());
//     response.stream.transform(utf8.decoder).listen((value) {
//       print(value);
//     });
//     return imgurl;
//   }
// }
