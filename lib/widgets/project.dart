import 'package:flutter/material.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/widgets/form_label.dart';

class ProjectEditForm extends StatefulWidget {
  final Project prj;
  ProjectEditForm({
    Key key,
    @required this.prj,
  })  : assert(prj != null),
        super(key: key);
  State<ProjectEditForm> createState() => _ProjectEditFormState();
}

class _ProjectEditFormState extends State<ProjectEditForm> {
  static const _formFieldPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);
  Project _prj;
  @override
  void initState() {
    super.initState();
    _prj = widget.prj;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FormLabelWidget('Name'),
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
                _prj.name = value;
              });
            },
            initialValue: _prj.name,
          ),
        )
      ],
    );
  }
}

// class _FormLabelWidget extends StatelessWidget {
//   final String data;

//   const _FormLabelWidget(this.data, {Key key})
//       : assert(data != null),
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         data,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 30,
//         ),
//       ),
//     );
//   }
// }
