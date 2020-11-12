// import "package:intl/intl.dart";

class Todo {
  String id;
  String title;
  String memo;
  String imageUrl;
  bool done;
  DateTime start;
  DateTime end;
  String personID;
  String projectID;
  //  追加
  bool notificationToggle;

  Todo({
    this.id,
    this.title,
    this.memo,
    this.imageUrl,
    this.done = false,
    this.start,
    this.end,
    this.personID,
    this.projectID,
    //  追加
    this.notificationToggle
  });

  Todo.fromMap(Map<String, dynamic> map)
      : this(
            id: map["id"],
            title: map["title"],
            memo: map["memo"],
            imageUrl: map["imageurl"],
            done: map["done"],
            start: DateTime.parse(map["start"]),
            end: DateTime.parse(map["end"]),
            personID: map["person"],
            projectID: map["projectid"],
            // 追加
            notificationToggle: map["notificationToggle"],);

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "title": this.title,
      "memo": this.memo,
      "imageurl": this.imageUrl,
      "done": this.done,
      "start": this.start.toIso8601String(),
      "end": this.end.toIso8601String(),
      "person": this.personID,
      "projectid": this.projectID,
      //  追加
      "notificationToggle": this.notificationToggle,
    };
  }
}
