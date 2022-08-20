import 'package:flutter/material.dart';
import 'package:nsfw_flutter/widgets/searchBar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../utils/arrayWindow.dart';
import 'categoryPage.dart';
import '../utils/tag.dart';
import '../api.dart';

const windowSize = 128;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Tag>> futureTags;
  ArrayWindow<Tag> arrW = ArrayWindow(length: 0);
  String? query;
  
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  void submit([String? str]){
    setState((){
      query = str;
    });
    fetchTagsCount(query: str)
      .then((value) => {
        setState((){
          arrW = ArrayWindow(
            length: value,
            windowSize: windowSize,
            future: fetchCategories(limit: windowSize, skip: 0, query: str)
          );
        })
    });
  }

  Future<List<Tag>> fetchCategories({String? query, required int limit, required int skip}){
    if(query == null){
      return fetchTags(skip: skip, limit: windowSize);
    }
    else{
      return fetchTags(query: query, skip: skip, limit: windowSize);
    }
  }

  List<int> get visibleItems {
    List<int> list = itemPositionsListener.itemPositions.value.map((elem) => elem.index).toList(growable: false);
    list.sort((a,b)=>a.compareTo(b));
    return list;
  }

  void visibleItemsListener () {
    List<int> visible = visibleItems;

    if(visible.isEmpty){
      return;
    }

    int lastGlobal = arrW.getGlobalIndex(visible.last);
    int firstGlobal = arrW.getGlobalIndex(visible.first);

    ArrayWindowStatus lastStatus = arrW.getStatus(lastGlobal);
    ArrayWindowStatus firstStatus =  arrW.getStatus(firstGlobal);
    WindowMovementDirection direction = WindowMovementDirection.none;

    if(firstStatus == ArrayWindowStatus.back){
      //print('back');
      direction = WindowMovementDirection.back;
    }

    if(lastStatus == ArrayWindowStatus.front){
      //print('front');
      direction = WindowMovementDirection.front;
    }

    if(direction == WindowMovementDirection.none){
      return;
    }

    final hint = arrW.getHint(direction);
    //print(visible);
    //print({'before': arrW.array[visible.first]});
    setState((){
      arrW.setFutureArray(
        future: fetchCategories(limit: hint['limit'] as int, skip: hint['skip'] as int, query: query),
        direction: direction,
        callback: ()=>{
          //print({'after': arrW.array[visibleItems.first - (hint['jump'] as int)]}),
          itemScrollController.jumpTo(index: visibleItems.first - (hint['jump'] as int) )
        }
      );
    });
  }

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(visibleItemsListener);

    fetchTagsCount()
      .then((value) => {
        setState((){
          arrW = ArrayWindow(
            length: value,
            windowSize: windowSize,
            future: fetchCategories(limit: windowSize, skip: 0)
          );
        })
    });
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