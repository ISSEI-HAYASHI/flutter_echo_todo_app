import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/repositories/image.dart';

class ImageField extends StatelessWidget {
  final File _file;
  ImageField({@required File file})
      : assert(file != null),
        this._file = file;
  @override
  Widget build(BuildContext context) {
    final onImageUploaded = StreamController<File>();
    final onImageUploadedStream = onImageUploaded.stream;
    final onImageUploadedSink = onImageUploaded.sink;
    // File _file;
    Future<int> showCupertinoBottomBar() {
      //選択するためのボトムシートを表示
      return showCupertinoModalPopup<int>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              message: Text('写真をアップロードしますか？'),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text(
                    'カメラで撮影',
                  ),
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text(
                    'アルバムから選択',
                  ),
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                isDefaultAction: true,
              ),
            );
          });
    }

    void showBottomSheet(_file) async {
      final result = await showCupertinoBottomBar();
      File imageFile;
      if (result == 0) {
        imageFile = await ImageUpload(ImageSource.camera).getImageFromDevice();
      } else if (result == 1) {
        imageFile = await ImageUpload(ImageSource.gallery).getImageFromDevice();
      }
      _file = imageFile;
      if (_file != null) {
        onImageUploadedSink.add(_file);
        onImageUploadedSink.close();
        onImageUploaded.close();
      }
    }

    return StreamBuilder(
        stream: onImageUploadedStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print("image field snapshot has data.");
            return Container(
                child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_file != null)
                      Container(
                        height: 150,
                        width: 150,
                        child: Image.file(_file),
                      ),
                    RaisedButton(
                      onPressed: () {
                        showBottomSheet(_file);
                      },
                      child: Text('画像を変更'),
                    ),
                  ]),
            ));
          } else {
            print("image field snapshot has no data.");
            return Container(
                child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (_oldFile != null)
                    //   Container(
                    //     height: 300,
                    //     width: 300,
                    //     child: Image.file(_oldFile),
                    //   ),
                    RaisedButton(
                      onPressed: () {
                        showBottomSheet(_file);
                      },
                      child: Text('写真を選択'),
                    ),
                  ]),
            ));
          }
        });
  }
}
