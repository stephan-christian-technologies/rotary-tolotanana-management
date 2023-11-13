class Operation {
  int? id;
  String name;

  Operation({this.id, required this.name});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Operation.fromMap(Map<String, dynamic> data) {
    return Operation(
      id: data['id'],
      name: data['name'],
    );
  }
}
