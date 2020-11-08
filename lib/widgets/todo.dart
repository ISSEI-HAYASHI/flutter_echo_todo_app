import 'package:flutter/material.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/repositories/constants.dart';
import 'package:todo_app/repositories/project.dart';
import 'package:todo_app/repositories/todo.dart';
import 'package:todo_app/repositories/user.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/utils/datetime.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/repositories/image.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(fontSize: 40),
                  ),
                  Row(
                    children: [
                      Icon(Icons.account_box),
                      FutureBuilder<User>(
                        future:
                            RESTUserRepository().retrieveUser(todo.personID),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("ユーザを取得中");
                          }
                          return Text("${snapshot.data.name}");
                        },
                      )
                    ],
                  )
                ],
              )),
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
  final String tempUrl;

  TodoEditForm(
      {Key key,
      @required this.todo,
      @required this.fileList,
      @required this.tempUrl})
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
  String _tempUrl;
  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
    _fileList = widget.fileList;
    _tempUrl = widget.tempUrl;
    _tempUrl = _todo.imageUrl;
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
                  if (_todo.projectID != "") {
                    _prjValue = _todo.projectID;
                  }
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
                    Container(
                        height: 150,
                        width: 150,
                        child: _tempUrl.isNotEmpty && _fileList[0].path == ""
                            ? Image.network(("$kHostUrl/" + _todo.imageUrl))
                            : Image.file(_fileList[0])),
                    RaisedButton(
                        onPressed: () {
                          showBottomSheet();
                        },
                        child: _tempUrl.isNotEmpty || _fileList[0].path != ""
                            ? Text('画像を変更')
                            : Text("画像を追加")),
                  ]),
            )),
            if (_tempUrl.isNotEmpty || _fileList[0].path != "")
              RaisedButton(
                child: const Text('削除'),
                onPressed: () {
                  setState(() {
                    if (_fileList[0].path != "") {
                      _fileList[0] = File("");
                    }
                    if (_todo.imageUrl.isNotEmpty) {
                      _tempUrl = "";
                    }
                  });
                },
              ),
          ],
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
    setState(() {
      _fileList[0] = imageFile;
    });
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

class TodoSearchWidget extends StatefulWidget {
  final Future<List<Todo>> todos;
  final int currentIndex;
  TodoSearchWidget({
    Key key,
    @required this.todos,
    @required this.currentIndex,
  })  : assert(todos != null),
        assert(currentIndex != null),
        super(key: key);

  State<TodoSearchWidget> createState() => _TodoSearchWidgetState();
}

class _TodoSearchWidgetState extends State<TodoSearchWidget> {
  final _formKey = GlobalKey<FormState>();
  final Future<List<User>> _users = RESTUserRepository().retrieveUsers();
  final Future<List<Project>> _prjs =
      RESTProjectRepository().retrieveProjects();
  List<String> _searchedUserIDs = [];
  List<String> _searchedProjectIDs = [];
  // Future<List<Todo>> _todos;
  int _currentIndex;

  // @override
  // void initState() {
  //   super.initState();
  //   _todos = widget.todos;
  //   _currentIndex = widget.currentIndex;
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text("検索"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    print(_searchedUserIDs);
                    print(_searchedProjectIDs);
                    Future<List<Todo>> searchedTodos = RESTTodoRepository()
                        .retrieveTodos(
                            users: _searchedUserIDs,
                            prjs: _searchedProjectIDs,
                            done: _currentIndex == 0 ? false : true);
                    setState(() {
                      // _todos = searchedTodos;
                      _searchedUserIDs = [];
                      _searchedProjectIDs = [];
                    });
                  }
                },
              ),
            ),
            Form(
                key: _formKey,
                child: SizedBox(
                    height: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: FutureBuilder(
                              future: _users,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    final user = snapshot.data[index];
                                    return CheckboxListTileFormField(
                                      dense: true,
                                      title: Text("${user.name}"),
                                      initialValue: false,
                                      onSaved: (value) {
                                        if (value) {
                                          print("user checked field");
                                          _searchedUserIDs.add(user.id);
                                        }
                                      },
                                      // validator: (bool value) {
                                      //   if (value) {
                                      //     return null;
                                      //   } else {
                                      //     return 'False!';
                                      //   }
                                      // },
                                    );
                                  },
                                );
                              }),
                        ),
                        SizedBox(
                            width: 200,
                            child: FutureBuilder(
                                future: _prjs,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      final prj = snapshot.data[index];
                                      return CheckboxListTileFormField(
                                        title: Text("${prj.name}"),
                                        dense: true,
                                        initialValue: false,
                                        onSaved: (value) {
                                          if (value) {
                                            _searchedProjectIDs.add(prj.id);
                                          }
                                        },
                                        // validator: (bool value) {
                                        //   if (value) {
                                        //     return null;
                                        //   } else {
                                        //     return 'False!';
                                        //   }
                                        // },
                                      );
                                    },
                                  );
                                })),
                      ],
                    ))),
          ],
        ));
  }
}
