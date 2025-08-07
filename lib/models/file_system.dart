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

  HiveFileSystem parsePath(String path) {
    if (path == "root") {
      return this;
    }
    final pathList = path.split("/");
    pathList.remove("root");
    HiveFileSystem files = this;
    for (var i = 0; i < pathList.length; i++) {
      files =
          files.children.firstWhere((element) => element.name == pathList[i]);
    }
    return files;
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
