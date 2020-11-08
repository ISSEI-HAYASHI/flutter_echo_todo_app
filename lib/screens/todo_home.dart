import 'package:flutter/material.dart';
// import 'package:flutter/semantics.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/widgets/dismiss_background.dart';
import 'package:todo_app/widgets/todo.dart';
import 'package:todo_app/repositories/todo.dart';
import 'package:todo_app/repositories/constants.dart';
import 'package:todo_app/repositories/image.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TodoHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  final _key = GlobalKey<ScaffoldState>();
  static final _widgetOptions = <Widget>[
    TodoList(),
    TodoDoneList(),
    SettingOptions(),
  ];
  Future<List<Todo>> _todos;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          _currentIndex != 2
              ? IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context, scrollController) => SizedBox(
                        height: 400,
                        child: TodoSearchWidget(
                          todos: _todos,
                          currentIndex: _currentIndex,
                        ),
                      ),
                    );
                  })
              : Container()
        ],
      ),
      body: _widgetOptions[_currentIndex],
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, kTodoCreationRouteName);
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Todo'),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Done'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "setting"),
        ],
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
    );
  }
}

abstract class TodoListBase extends StatefulWidget {}

abstract class TodoListStateBase extends State<TodoListBase> {
  final DismissBackground leftSideBackground = null;
  GlobalKey<ScaffoldState> key;
  @override
  // void initState() {
  //   _todos = widget.todos;
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    key = context.findAncestorWidgetOfExactType<Scaffold>().key;
    final _todos = getTodos();
    return FutureBuilder<List<Todo>>(
      future: _todos,
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
            final todo = snapshot.data[index];
            return Dismissible(
              key: Key('${todo.id}'),
              background: leftSideBackground,
              secondaryBackground: const DismissDeletionBackground(),
              child: TodoSummaryWidget(todo: todo),
              onDismissed: generateOnDismissedFunc(snapshot.data, todo, index),
            );
          },
        );
      },
    );
  }

  Future<List<Todo>> getTodos();

  void Function(DismissDirection) generateOnDismissedFunc(
      List<Todo> todos, Todo todo, int index);
}

class TodoList extends TodoListBase {
  // final Future<List<Todo>> todos;
  // TodoList({Key key, @required this.todos}) : assert(todos != null);

  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends TodoListStateBase {
  @override
  final leftSideBackground = const DismissDoneBackground();

  @override
  Future<List<Todo>> getTodos() {
    return RESTTodoRepository()
        .retrieveTodos(users: [kUserID], prjs: [], done: false);
  }

  @override
  void Function(DismissDirection) generateOnDismissedFunc(
      List<Todo> todos, Todo todo, int index) {
    final String userID = kUserID;
    if (userID != todo.personID) {
      String message = "not your todo.";
      setState(() {
        key.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('“${todo.title}” was $message.'),
            ),
          );
      });
    }
    return (direction) {
      String message;
      switch (direction) {
        case DismissDirection.startToEnd:
          todo.done = true;
          RESTTodoRepository().updateTodo(todo);
          message = 'done';
          break;
        case DismissDirection.endToStart:
          RESTTodoRepository().deleteTodo(todo);
          message = 'deleted';
          break;
        default:
          return;
      }
      setState(() {
        todos.removeAt(index);
        key.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('“${todo.title}” was $message.'),
              action: SnackBarAction(
                label: 'discard',
                onPressed: () {
                  if (message == 'done') {
                    todo.done = false;
                    RESTTodoRepository().updateTodo(todo);
                  } else if (message == 'deleted') {
                    RESTTodoRepository().createTodo(todo);
                  }
                  setState(() {
                    todos.insert(index, todo);
                  });
                },
              ),
            ),
          ).closed.then((value) {
            if (value != SnackBarClosedReason.action &&
                message == 'deleted' &&
                todo.imageUrl.isNotEmpty) {
              DeleteImage().delete(todo.imageUrl);
            }
          });
      });
    };
  }
}

class TodoDoneList extends TodoListBase {
  // final Future<List<Todo>> todos;
  // TodoDoneList({Key key, @required this.todos}) : assert(todos != null);
  @override
  State<StatefulWidget> createState() => TodoDoneListState();
}

class TodoDoneListState extends TodoListStateBase {
  @override
  final leftSideBackground = const DismissUndoBackground();

  @override
  Future<List<Todo>> getTodos() {
    return RESTTodoRepository()
        .retrieveTodos(users: [kUserID], prjs: [], done: true);
  }

  @override
  void Function(DismissDirection) generateOnDismissedFunc(
      List<Todo> todos, Todo todo, int index) {
    return (direction) {
      String message;
      switch (direction) {
        case DismissDirection.startToEnd:
          todo.done = false;
          RESTTodoRepository().updateTodo(todo);
          message = 'undone';
          break;
        case DismissDirection.endToStart:
          RESTTodoRepository().deleteTodo(todo);
          message = 'deleted';
          break;
        default:
          return;
      }
      setState(() {
        todos.removeAt(index);
        key.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('“${todo.title}” was $message.'),
              action: SnackBarAction(
                label: 'discard',
                onPressed: () {
                  if (message == 'undone') {
                    todo.done = true;
                    RESTTodoRepository().updateTodo(todo);
                  } else if (message == 'deleted') {
                    RESTTodoRepository().createTodo(todo);
                  }
                  setState(() {
                    todos.insert(index, todo);
                  });
                },
              ),
            ),
          ).closed.then((value) {
            if (value != SnackBarClosedReason.action &&
                message == 'deleted' &&
                todo.imageUrl.isNotEmpty) {
              DeleteImage().delete(todo.imageUrl);
            }
          });
      });
    };
  }
}

class SettingOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 200,
              child: RaisedButton.icon(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                label: const Text('notification'),
                onPressed: () {},
                color: Colors.grey,
                textColor: Colors.white,
              )),
          SizedBox(
            width: 200,
            child: RaisedButton.icon(
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              ),
              label: const Text('project'),
              onPressed: () {
                Navigator.pushNamed(context, kProjectListRouteName);
              },
              color: Colors.grey,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
