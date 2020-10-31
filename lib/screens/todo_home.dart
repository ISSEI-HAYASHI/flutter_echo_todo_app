import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/widgets/dismiss_background.dart';
import 'package:todo_app/widgets/todo.dart';
// import 'package:todo_app/widgets/image_field.dart';
import 'package:todo_app/repositories/todo.dart';
import 'package:todo_app/repositories/constants.dart';

class TodoHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  final _key = GlobalKey<ScaffoldState>();
  static final _widgetOptions = <Widget>[
    TodoList(),
    TodoDoneList(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: _widgetOptions[_currentIndex],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, kTodoCreationRouteName);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Todo'),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Done'),
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
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends TodoListStateBase {
  @override
  final leftSideBackground = const DismissDoneBackground();

  @override
  Future<List<Todo>> getTodos() {
    return RESTTodoRepository().retrieveTodos(userID: kUserID, done: false);
  }

  @override
  void Function(DismissDirection) generateOnDismissedFunc(
      List<Todo> todos, Todo todo, int index) {
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
        print(DateTime.now());
        // print(index);
        // print(todos);
        todos.removeAt(index);
        // print(todos);
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
              debugPrint("deleting image tobe here.");
              // todo.imageUrl.deleteSync();
            }
          });
      });
    };
  }
}

class TodoDoneList extends TodoListBase {
  @override
  State<StatefulWidget> createState() => TodoDoneListState();
}

class TodoDoneListState extends TodoListStateBase {
  @override
  final leftSideBackground = const DismissUndoBackground();

  @override
  Future<List<Todo>> getTodos() {
    return RESTTodoRepository().retrieveTodos(userID: kUserID, done: true);
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
              // todo.imageFile.deleteSync();
              debugPrint("deleting image tobe here.");
            }
          });
      });
    };
  }
}
