import 'package:flutter/material.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/project.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/utils/datetime.dart';
// import 'package:todo_app/widgets/image_field.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/repositories/image.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';

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
  String _prjValue;
  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
    _fileList = widget.fileList;
    if (_todo.imageUrl != null) {
      _fileList[0] = File(_todo.imageUrl);
    }
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
        const _FormLabelWidget("Project"),
        Padding(
            padding: _formFieldPadding,
            child: FutureBuilder<List<Map<String, String>>>(
              future: _generateProjectDataSource(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("プロジェクトを取得中");
                } else {
                  return DropDownFormField(
                    filled: false,
                    titleText: "",
                    hintText: "Choose a project.",
                    value: _prjValue,
                    onChanged: (value) {
                      setState(() {
                        _prjValue = value;
                        _todo.projectID = value;
                        print(_todo.projectID);
                      });
                    },
                    dataSource: snapshot.data,
                    textField: "display",
                    valueField: "value",
                  );
                }
              },
            )),
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

  Future<List<Map<String, String>>> _generateProjectDataSource() async {
    List<Project> prjList = await RESTProjectRepository().retrieveProjects();
    return prjList.map((e) {
      return {
        "display": e.name,
        "value": e.id,
      };
    }).toList();
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
