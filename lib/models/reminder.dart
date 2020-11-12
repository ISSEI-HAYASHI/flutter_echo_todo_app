import 'package:meta/meta.dart';

class Reminder {
  final String time;
  final String name;

  const Reminder({
    @required this.time,
    @required this.name,
  });

  static Reminder fromJson(dynamic json) {
    return json != null
        ? new Reminder(
        time: json["time"],
        name: json["name"])
        : null;
  }

  dynamic toJson() {
    return {
      "time": time,
      "name": name,
    };
  }
}