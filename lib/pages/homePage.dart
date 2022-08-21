import 'package:flutter/material.dart';
import 'package:nsfw_flutter/utils/infiniteScroll.dart';
import 'package:nsfw_flutter/widgets/searchBar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../utils/arrayWindow.dart';
import 'categoryPage.dart';
import '../utils/tag.dart';
import '../api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with InfiniteScroll<HomePage,Tag> {
  String? query;

  void submit([String? str]){
    setState((){
      query = str;
    });
    fetchTagsCount(query: str)
      .then((value) => {
        initialFetch(length: value)
    });
  }

  Future<List<Tag>> fetchCategories({required int limit, required int skip}){
    if(query == null){
      return fetchTags(skip: skip, limit: limit);
    }
    else{
      return fetchTags(query: query, skip: skip, limit: limit);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchFunction = fetchCategories;
    arrW = ArrayWindow(length: 0);

    attachListener();

    fetchTagsCount()
      .then((value) => {
        initialFetch(length: value)
    });
  }

  @override
  void dispose() {
    
    detachListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter NSFW Example',
      home: Scaffold(
        appBar: SearchBar(
          submit: submit,
          cancel: (){submit();},
          title: 'Flutter NSFW',
          label: 'search for category'
        ),
        body: FutureBuilder <List<Tag>>(
          future: arrW.futureArray,
          builder: (context, snapshot) {
            if (snapshot.hasData) {

              return ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                itemCount: arrW.array.length,
                itemBuilder: (context, index){
                  return ListTile( //map((gif) => ListTile(
                    onTap: () {
                      Navigator.push(context, 
                        MaterialPageRoute(
                          builder: (_)=> CategoryPage(tag: arrW.array[index], index: 0),
                        ),
                      );
                    },
                    title: Text(arrW.array[index].name),
                    subtitle: Text(arrW.array[index].count.toString()),
                  );
                } 
              );

            } else if (snapshot.hasError) {
              throw {snapshot.error};
              //return Text("${snapshot.error}");
            }
            // By default show a loading spinner.
            return const Center( child:CircularProgressIndicator() );
          },
        ),
      ),
    );
  }
}