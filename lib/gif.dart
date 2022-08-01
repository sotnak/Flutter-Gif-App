class Gif {
  final String title;
  final String url;
  final List<String> tags;

  @override
  String toString() {
    return 'title: $title, url: $url';
  }

  const Gif({
    required this.title,
    required this.url,
    required this.tags,
  });

  factory Gif.fromJson(Map<String, dynamic> json) {
    return Gif(
      title: json['title'],
      url: json['url'],
      tags: (json['tags'] as List<dynamic>).map((tag) => tag as String).toList(),
    );
  }
}