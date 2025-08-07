class HiveFileSystem {
  String name;
  List<HiveFileSystem> children;

  HiveFileSystem({required this.name, required this.children});

  factory HiveFileSystem.fromMap(Map<String, dynamic> map) {
    final name = map.keys.first;
    bool isFile = name.contains('.');
    late final List<HiveFileSystem> children;
    children = isFile
        ? []
        : List<HiveFileSystem>.from(
            map.values.first.map((x) => HiveFileSystem.fromMap(x)));

    if (isFile) {
      return HiveFile(
        name: name,
        content: map.values.first,
      );
    }
    return HiveFileSystem(name: name, children: children);
  }

  bool get isDirectory => !name.contains('.');
}

class HiveFile extends HiveFileSystem {
  String content;

  HiveFile({required this.content, required super.name}) : super(children: []);
}

class HiveDirectory {
  String name;
  List<HiveFileSystem> children;

  HiveDirectory({required this.name, required this.children});
}
