import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nsfw_flutter/security.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/gif.dart';
import 'utils/tag.dart';

final String? host = dotenv.env['API_URL'];

const int randomLimit = 100;

Future<List<Tag> >fetchTags({required int limit, required int skip, String? query }) async{
  String url = '$host/tags?limit=$limit&skip=$skip';

  if(query != null){
    url += '&query=$query';
  }
  
  String hash = getAuth();
  var response = await http.get(Uri.parse(url), headers: {'Authorization':hash});

  if (response.statusCode != 200) {
    throw Exception('Failed to load tags (${response.statusCode})');
  }

  List<dynamic> decoded = jsonDecode(response.body).toList();

  List<Tag> tags = decoded.map((tag) => Tag.fromJson(tag)).toList(growable: true);

  if(query != null){
    return tags;
  }

  tags.insert(0, const Tag(name: 'RANDOM', count: randomLimit));

  return tags;
}

Future<List<Gif>> fetchGifsByTag({required String tag, required int limit, required int skip}) async {
  if(tag == 'RANDOM'){
    limit = randomLimit;
  }

  String hash = getAuth();
  var response = await http.get(Uri.parse('$host/gifs?tag=$tag&limit=$limit&skip=$skip'), headers: {'Authorization':hash});

  if (response.statusCode != 200) {
    throw Exception('Failed to load tags (${response.statusCode})');
  }

  List<dynamic> decoded = jsonDecode(response.body).toList();

  List<Gif> gifs = decoded.map((gif) => Gif.fromJson(gif)).toList();

  return gifs;
}

Future<int> fetchTagsCount({String? query}) async {
  String url = '$host/tagsCount';

  if(query != null){
    url += '?query=$query';
  }

  String hash = getAuth();
  var response = await http.get(Uri.parse(url), headers: {'Authorization':hash});

  Map<String, dynamic> decoded = jsonDecode(response.body);

  //+1 for RANDOM
  return (decoded['count'] as int) + 1;
}