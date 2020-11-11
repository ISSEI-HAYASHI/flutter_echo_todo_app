import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/utils/datetime.dart';
// import 'package:todo_app/widgets/image_field.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/repositories/image.dart';
//追加
import 'package:todo_app/repositories/todo.dart';
import 'package:todo_app/store/store.dart';
import 'package:todo_app/actions/actions.dart';
import 'package:todo_app/notification/notificationHelper.dart';
import 'package:todo_app/main.dart';
//ここまで

class TodoSummaryWidget extends StatelessWidget {
  final Todo todo;
  TodoSummaryWidget({Key key, @required this.todo}) : assert(todo != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              todo.title,
              style: TextStyle(fontSize: 40),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('time duration'
                      // todo.displayTimeDuration(),
                      // style: TextStyle(
                      //   color: DateTime.now().difference(todo.start).isNegative
                      //       ? Colors.black
                      //       : Colors.red,
                      // ),
                      ),
                  // Text('@${todo.displayPlace()}'),
                ],
              ),

              // 追加
              // 通知の切り替えボタン追加
              if(todo.notificationToggle == true)
                IconButton(
                  iconSize: 30,
                  onPressed: (){toggleBtn(todo, context);},
                  icon: Icon(
                    Icons.add_alert,
                    color: Colors.blue,
                  ),
                ),
              if(todo.notificationToggle != true)
              // else
                IconButton(
                  iconSize: 30,
                  onPressed: (){toggleBtn(todo, context);},
                  icon: Icon(
                    Icons.add_alert,
                    color: Colors.grey,
                  ),
                ),
              // ここまで

              RaisedButton(
                child: const Text('view detail'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    kTodoDetailRouteName,
                    arguments: todo,
                  );
                },
              ),
            ],
          ),
          // todo.imageUrl.isEmpty ? Container() : Container()
          //Image.file(todo.imageFile, width: 240),
        ],
      ),
    );
  }

  // 追加
  // 通知のtoggleを変更して更新
  Future<void> toggleBtn(Todo todo, BuildContext context) async{
    bool flag;
    print(todo.notificationToggle);
    if(todo.notificationToggle == false){
      flag = true;
      // 通知を設定する関数へ渡す
      var notificationDatetime = todo.start;
      print(todo.start);
      _configureCustomReminder(flag, todo.id, todo.title, todo.memo, notificationDatetime);
    }
    else{
      flag = false;
    }
    final renewTodo = Todo(
      id: todo.id,
      title: todo.title,
      memo: todo.memo,
      imageUrl: todo.imageUrl,
      genre: todo.genre,
      done: todo.done,
      start: todo.start,
      end: todo.end,
      personID: todo.personID,
      notificationToggle: flag,
    );
    await RESTTodoRepository().updateTodo(renewTodo);
    Navigator.pushNamedAndRemoveUntil(
      context,
      kTodoHomeRouteName,
          (route) => false,
    );
  }

  //  時間指定の通知を設定
  void _configureCustomReminder(
      bool value,
      String id,
      String notificationTitle,
      String notificationName,
      DateTime notificationDatetime
      ) {
    if (value == true) {
      var notificationTime = new DateTime(
        notificationDatetime.year,
        notificationDatetime.month,
        notificationDatetime.day,
        notificationDatetime.hour,
        notificationDatetime.minute,
      );

      // 例えば毎朝7時に鳴らすとかだとこんな感じ
      // var notificationTime = new DateTime(
      //   notificationDatetime.year,
      //   notificationDatetime.month,
      //   notificationDatetime.day,
      //   7,
      //   0,
      // );

      // appStateReducerへ
      getStore().dispatch(
          SetReminderAction(
            time: notificationTime.toIso8601String(),
            name: notificationTitle,
          )
      );

      // notificationHelperへ
      scheduleNotification(
        flutterLocalNotificationsPlugin,
        // id,
        // 本来であればここに予定のidが入り、ひとつの予定につき1回通知を鳴らすのだが、
        // flutterLocalNotificationsPluginの都合でintのidしか入力できないため、
        // 応急処置で1を入れている（1個しか通知を鳴らせない状態）
        1,
        notificationTitle,
        notificationName,
        notificationTime,
      );
    } else {
      getStore().dispatch(RemoveReminderAction('custom'));
      turnOffNotificationById(
        flutterLocalNotificationsPlugin,
        // id,
        // 本来であればここに予定のidが入り、ひとつの予定につき1回通知を鳴らすのだが、
        // flutterLocalNotificationsPluginの都合でintのidしか入力できないため、
        // 応急処置で1を入れている（1個しか通知を鳴らせない状態）
        1,
      );
    }
  }
  // ここまで

}

class TodoEditForm extends StatefulWidget {
  final Todo todo;
  final List<File> fileList;

  TodoEditForm({Key key, @required this.todo, @required this.fileList})
      : assert(todo != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoEditFormState();
}

class _TodoEditFormState extends State<TodoEditForm> {
  static const _formFieldPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);
  static const _timeFieldPadding = EdgeInsets.fromLTRB(64, 0, 32, 0);
  static const _formFieldSeperatorPadding = EdgeInsets.symmetric(horizontal: 8);
  static const _dateSeperator = _FormSeperatorWidget('/');
  static const _timeSeperator = _FormSeperatorWidget(':');
  static final _monthDropdownMenuItem = _generateDropdownMenu(12, offset: 1);
  static final _hourDropdownMenuItem = _generateDropdownMenu(24);
  static final _minuteDropdownMenuItem = _generateDropdownMenu(60);

  Todo _todo;
  List<File> _fileList;
  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
    _fileList = widget.fileList;
    // print(_todo.imageUrl);
    if (_todo.imageUrl != null) {
      _fileList[0] = File(_todo.imageUrl);
    }
    // _file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FormLabelWidget('Title'),
        Padding(
          padding: _formFieldPadding,
          child: TextFormField(
            validator: (value) {
              if (value == '') {
                return 'Please enter title';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _todo.title = value;
              });
            },
            initialValue: _todo.title,
          ),
        ),
        const _FormLabelWidget('Schedule'),
        Padding(
          padding: _formFieldPadding,
          child: Column(
            children: [
              Row(
                children: [
                  // Year
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      items: _generateYearDropdownMenu(),
                      onChanged: (value) {
                        setState(() {
                          _todo.start = updateYear(_todo.start, value);
                        });
                      },
                      value: _todo.start.year,
                    ),
                  ),
                  _dateSeperator,
                  // Month
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField(
                      items: _monthDropdownMenuItem,
                      onChanged: (value) {
                        setState(() {
                          _todo.start = updateMonth(_todo.start, value);
                        });
                      },
                      value: _todo.start.month,
                    ),
                  ),
                  _dateSeperator,
                  // Day
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField(
                      items: _generateDayDropdownMenu(dt: _todo.start),
                      onChanged: (value) {
                        setState(() {
                          _todo.start = updateDay(_todo.start, value);
                        });
                      },
                      value: _todo.start.day,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: _timeFieldPadding,
                child: Row(
                  children: [
                    // Hour
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField(
                        items: _hourDropdownMenuItem,
                        onChanged: (value) {
                          setState(() {
                            _todo.start = updateHour(_todo.start, value);
                          });
                        },
                        value: _todo.start.hour,
                      ),
                    ),
                    _timeSeperator,
                    // Minute
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField(
                        items: _minuteDropdownMenuItem,
                        onChanged: (value) {
                          setState(() {
                            _todo.start = updateMinute(_todo.start, value);
                          });
                        },
                        value: _todo.start.minute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: _formFieldSeperatorPadding,
          child: RotatedBox(
            quarterTurns: 1,
            child: Text('~', style: TextStyle(fontSize: 24)),
          ),
        ),
        Padding(
          padding: _formFieldPadding,
          child: Column(
            children: [
              Row(
                children: [
                  // Year
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      items: _generateYearDropdownMenu(),
                      onChanged: (value) {
                        setState(() {
                          _todo.end = updateYear(_todo.end, value);
                        });
                      },
                      value: _todo.end?.year,
                    ),
                  ),
                  _dateSeperator,
                  // Month
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField(
                      items: _monthDropdownMenuItem,
                      onChanged: (value) {
                        setState(() {
                          _todo.end = updateMonth(_todo.end, value);
                        });
                      },
                      value: _todo.end?.month,
                    ),
                  ),
                  _dateSeperator,
                  // Day
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField(
                      items: _generateDayDropdownMenu(dt: _todo.end),
                      onChanged: (value) {
                        setState(() {
                          _todo.end = updateDay(_todo.end, value);
                        });
                      },
                      value: _todo.end?.day,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: _timeFieldPadding,
                child: Row(
                  children: [
                    // Hour
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField(
                        items: _hourDropdownMenuItem,
                        onChanged: (value) {
                          setState(() {
                            _todo.end = updateHour(_todo.end, value);
                          });
                        },
                        value: _todo.end?.hour,
                      ),
                    ),
                    _timeSeperator,
                    // Minute
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField(
                        items: _minuteDropdownMenuItem,
                        onChanged: (value) {
                          setState(() {
                            _todo.end = updateMinute(_todo.end, value);
                          });
                        },
                        value: _todo.end?.minute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const _FormLabelWidget('Memo'),
        Padding(
          padding: _formFieldPadding,
          child: TextFormField(
            onChanged: (value) {
              setState(() {
                _todo.memo = value;
              });
            },
            maxLines: 7,
            initialValue: _todo.memo,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const _FormLabelWidget('Image'),
            Container(
                child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Image.file(_fileList[0]) != null)
                      Container(
                        height: 150,
                        width: 150,
                        child: Image.file(_fileList[0]),
                      ),
                    RaisedButton(
                      onPressed: () {
                        showBottomSheet();
                      },
                      child: Text('画像を変更'),
                    ),
                  ]),
            )),
            // StreamBuilder(
            //     stream: onImageUploadedStream,
            //     builder: (BuildContext context, AsyncSnapshot snapshot) {
            //       if (snapshot.hasData) {
            //         print("image field snapshot has data.");
            //         print(_file);
            //         // setState(() {
            //         //   print("file set state");
            //         //   _file = _file;
            //         // });
            //         return Container(
            //             child: SingleChildScrollView(
            //           child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 if (_file != null)
            //                   Container(
            //                     height: 150,
            //                     width: 150,
            //                     child: Image.file(_file),
            //                   ),
            //                 RaisedButton(
            //                   onPressed: () {
            //                     showBottomSheet();
            //                   },
            //                   child: Text('画像を変更'),
            //                 ),
            //               ]),
            //         ));
            //       } else {
            //         print("image field snapshot has no data.");
            //         return Container(
            //             child: SingleChildScrollView(
            //           child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 // if (_oldFile != null)
            //                 //   Container(
            //                 //     height: 300,
            //                 //     width: 300,
            //                 //     child: Image.file(_oldFile),
            //                 //   ),
            //                 RaisedButton(
            //                   onPressed: () {
            //                     showBottomSheet();
            //                   },
            //                   child: Text('写真を選択'),
            //                 ),
            //               ]),
            //         ));
            //       }
            //     }),
            RaisedButton(
              child: const Text('削除'),
              onPressed: () {
                setState(() {
                  if (_todo.imageUrl.isNotEmpty) {
                    debugPrint('deleting image to be here');
                    // _todo.imageFile.deleteSync();
                  }
                  _todo.imageUrl = '';
                });
              },
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: _todo.imageUrl == '' ? Text('No image') : Container()
            // : Image.file(
            //     _todo.imageFile,
            //     width: 240,
            //   ),
            ),
      ],
    );
  }

  static List<DropdownMenuItem<int>> _generateDropdownMenu(int count,
      {int offset = 0}) {
    return List<DropdownMenuItem<int>>.generate(
      count,
      (index) {
        final v = offset + index;
        return DropdownMenuItem(
          child: Text('$v'),
          value: v,
        );
      },
      growable: false,
    );
  }

  List<DropdownMenuItem<int>> _generateYearDropdownMenu() {
    return _generateDropdownMenu(10, offset: DateTime.now().year);
  }

  List<DropdownMenuItem<int>> _generateDayDropdownMenu({DateTime dt}) {
    int days = daysInCurrentMonth(dt ?? DateTime.now());
    return _generateDropdownMenu(days, offset: 1);
  }

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

  void showBottomSheet() async {
    final result = await showCupertinoBottomBar();
    File imageFile;
    if (result == 0) {
      imageFile = await ImageUpload(ImageSource.camera).getImageFromDevice();
    } else if (result == 1) {
      imageFile = await ImageUpload(ImageSource.gallery).getImageFromDevice();
    }
    _fileList[0] = imageFile;
    if (Image.file(_fileList[0]) != null) {
      setState(() {
        print("file set state");
        _fileList[0] = imageFile;
      });
    }
  }

  // Future<void> _getImage() async {
  //   final picked = await _picker.getImage(
  //     source: ImageSource.gallery,
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       // _image = File(picked.path);
  //       if (_todo.imageUrl.isNotEmpty) {
  //         debugPrint('deleting image to be here');
  //         // _todo.imageFile.deleteSync();
  //       }
  //       _todo.imageUrl = picked.path;
  //     });
  //   }
  // }
}

class _FormLabelWidget extends StatelessWidget {
  final String data;

  const _FormLabelWidget(this.data, {Key key})
      : assert(data != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        data,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }
}

class _FormSeperatorWidget extends StatelessWidget {
  static const _formFieldSeperatorPadding = EdgeInsets.symmetric(horizontal: 8);
  final String data;

  const _FormSeperatorWidget(this.data, {Key key})
      : assert(data != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _formFieldSeperatorPadding,
      child: Text(data),
    );
  }
}
