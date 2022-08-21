import 'package:flutter/material.dart';
import 'package:nsfw_flutter/utils/infiniteScroll.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:nsfw_flutter/pages/gifPage.dart';
import 'package:nsfw_flutter/api.dart';
import 'package:nsfw_flutter/utils/tag.dart';
import '../utils/gif.dart';

const Duration scrollDuration = Duration(milliseconds: 500);

class CategoryPage extends StatefulWidget {
  final Tag tag;
  final int index;

  const CategoryPage({Key? key, required this.tag, required this.index}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with InfiniteScroll<CategoryPage, Gif> {

  Future<List<Gif>> fetchPage({required int limit, required int skip}) {

    return fetchGifsByTag(tag: widget.tag.name, limit: limit, skip: skip);
  }

  @override
  void initState() {
    super.initState();

    fetchFunction = fetchPage;

    attachListener();
    
    initialFetch(length: widget.tag.count);
  }

  @override
  void dispose() {

    detachListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag.name),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder <List<Gif>>(
        future: arrW.futureArray,
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            return ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemCount: arrW.array.length,
              itemBuilder: (context, index) {
                return ListTile( //map((gif) => ListTile(
                  onTap: () {
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (_)=> GifPage(index: arrW.getGlobalIndex(index), tag: widget.tag ),
                      ),
                    );
                  },
                  title: Text('${arrW.getGlobalIndex(index)}. ${arrW.array[index].title}'),
                  subtitle: Text(arrW.array[index].tags.toString()),
                );
              },
            );
          }
          else if (snapshot.hasError) {
            throw {snapshot.error};
            //return Text("${snapshot.error}");
          }
          // By default show a loading spinner.
          return const Center( child:CircularProgressIndicator());
        },
      ),
    );
  }
}