class Project {
  String id;
  String name;

  Project({
    this.id,
    this.name,
  });

  Project.fromMap(Map<String, dynamic> map)
      : this(
          id: map["id"],
          name: map["name"],
        );

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "name": this.name,
    };
  }
}
