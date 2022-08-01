import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'gif.dart';
import 'tag.dart';

const String host = '192.168.0.99';
const String port = '27017';

Future<List<Tag> >fetchTags() async{
  var db = mongo.Db('mongodb://$host:$port/nsfw');
  await db.open();
  var collection = db.collection('tags');
  var tags = (await collection.find().toSet()).map((event) => Tag.fromJson(event)).toList();

  db.close();

  tags.sort(((a, b) => b.count.compareTo(a.count)));

  return tags;
}

Future<List<Tag> >searchTags(String query) async{
  var db = mongo.Db('mongodb://$host:$port/nsfw');
  await db.open();
  var collection = db.collection('tags');
  var tags = (await collection.find(mongo.where.match('name', query)).toSet()).map((event) => Tag.fromJson(event)).toList();
  db.close();

  tags.sort(((a, b) => b.count.compareTo(a.count)));

  return tags;
}

Future<List<Gif>> fetchGifsByTag({required String tag, required int limit, required int skip}) async {
  var db = mongo.Db('mongodb://$host:$port/nsfw');
  await db.open();
  var collection = db.collection('gifs');

  List<Gif> gifs = [];

  var selector = mongo.where.skip(skip).limit(limit);

  if(tag != 'all') {
    selector = selector.eq('tags', tag);
  }

  gifs = (await collection.find(selector).toSet()).map((event) => Gif.fromJson(event)).toList();

  db.close();

  return gifs;
}