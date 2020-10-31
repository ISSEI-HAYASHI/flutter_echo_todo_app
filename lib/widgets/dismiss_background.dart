import 'package:flutter/material.dart';

class DismissBackground extends StatelessWidget {
  final Color color;
  final AlignmentGeometry alignment;
  final IconData icon;

  const DismissBackground({Key key, this.color, this.alignment, this.icon})
      : assert(color != null),
        assert(alignment != null),
        assert(icon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: EdgeInsets.only(left: 24, right: 24),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class DismissDeletionBackground extends DismissBackground {
  const DismissDeletionBackground({Key key})
      : super(
          key: key,
          color: Colors.red,
          alignment: Alignment.centerRight,
          icon: Icons.delete,
        );
}

class DismissDoneBackground extends DismissBackground {
  const DismissDoneBackground({Key key})
      : super(
          key: key,
          color: Colors.green,
          alignment: Alignment.centerLeft,
          icon: Icons.done,
        );
}

class DismissUndoBackground extends DismissBackground {
  const DismissUndoBackground({Key key})
      : super(
          key: key,
          color: Colors.blue,
          alignment: Alignment.centerLeft,
          icon: Icons.undo,
        );
}
