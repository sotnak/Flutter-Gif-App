import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nsfw_flutter/security.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/gif.dart';
import 'utils/tag.dart';

String? host = dotenv.env['API_URL'];

Future<List<Tag> >fetchTags() async{
  String hash = getAuth();
  var response = await http.get(Uri.parse('$host/tags'), headers: {'Authorization':hash});

  if (response.statusCode != 200) {
    throw Exception('Failed to load tags');
  }

  List<dynamic> decoded = jsonDecode(response.body).toList();

  List<Tag> tags = decoded.map((tag) => Tag.fromJson(tag)).toList();

  tags.sort(((a, b) => b.count.compareTo(a.count)));

  return tags;
}

Future<List<Tag> >searchTags(String query) async{
  String hash = getAuth();
  var response = await http.get(Uri.parse('$host/tags?query=$query'), headers: {'Authorization':hash});

  if (response.statusCode != 200) {
    throw Exception('Failed to load tags');
  }

  List<dynamic> decoded = jsonDecode(response.body).toList();

  List<Tag> tags = decoded.map((tag) => Tag.fromJson(tag)).toList();

  tags.sort(((a, b) => b.count.compareTo(a.count)));

  return tags;
}

Future<List<Gif>> fetchGifsByTag({required String tag, required int limit, required int skip}) async {
  String hash = getAuth();
  var response = await http.get(Uri.parse('$host/gifs?tag=$tag&limit=$limit&skip=$skip'), headers: {'Authorization':hash});

  if (response.statusCode != 200) {
    throw Exception('Failed to load gifs');
  }

  List<dynamic> decoded = jsonDecode(response.body).toList();

  List<Gif> gifs = decoded.map((gif) => Gif.fromJson(gif)).toList();

  return gifs;
}