class Tag {
  final String name;
  final int count;

  @override
  String toString() {
    return '{name: $name, count: $count}';
  }

  const Tag({
    required this.name,
    required this.count,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'],
      count: json['count'],
    );
  }
}