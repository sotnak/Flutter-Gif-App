import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:nsfw_flutter/gifPage.dart';
import 'package:nsfw_flutter/mongo.dart';
import 'package:nsfw_flutter/tag.dart';
import 'gif.dart';

const int limit = 64;
const Duration scrollDuration = Duration(milliseconds: 500);

class CategoryPage extends StatefulWidget {
  final Tag tag;
  final int index;

  const CategoryPage({Key? key, required this.tag, required this.index}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  late Future<List<Gif>> futureGifs;
  int currentPage = 0;
  int pageCount = 1;
  bool isFetching = true;

  late ItemScrollController itemScrollController;

  @override
  void initState() {
    super.initState();
    itemScrollController = ItemScrollController();

    currentPage = (widget.index / limit).floor();
    pageCount = (widget.tag.count.toDouble() / limit.toDouble()).ceil();
    int onPageIndex = widget.index - currentPage * limit;
    
    fetchPage();

    futureGifs.whenComplete(() => Future.delayed(const Duration(milliseconds: 100))).whenComplete(() => scrollTo(onPageIndex));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scrollUp(){
    itemScrollController.scrollTo(index: 0, duration: scrollDuration);
  }

  void scrollTo(int index){
    itemScrollController.scrollTo(index: index, duration: scrollDuration);
  }

  void fetchPage(){
    isFetching = true;

    //futureGifs = Future.any([]);
  
    futureGifs = fetchGifsByTag(tag: widget.tag.name, limit: limit, skip: limit * currentPage);
    futureGifs.then((value) => {isFetching=false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag.name),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder <List<Gif>>(
        future: futureGifs,
        builder: (context, snapshot) {
          if (snapshot.hasData && !isFetching) {
            List<Gif> gifs = snapshot.data ?? [];

            return ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemCount: gifs.length,
              scrollDirection: Axis.vertical,
              addAutomaticKeepAlives: true,
              itemBuilder: (context, index) {
                return ListTile( //map((gif) => ListTile(
                  onTap: () {
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (_)=> GifPage(index: index + currentPage * limit, tag: widget.tag ),
                      ),
                    );
                  },
                  title: Text('${index + currentPage * limit}. ${gifs[index].title}'),
                  subtitle: Text(gifs[index].tags.toString()),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.navigate_before),
            label: 'prev',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.panorama_vertical),
            label: '${currentPage + 1} / $pageCount',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.navigate_next),
            label: 'next',
          )
        ],
        onTap: (button){
          
          if(isFetching){
            return;
          }

          switch(button){
            case 0:
              if(currentPage > 0){
                scrollUp();

                setState(() {
                  currentPage--;
                  fetchPage();
                });
              }
              break;
            case 2:
              if(currentPage+1<pageCount){
                scrollUp();

                setState(() {
                  currentPage++;
                  fetchPage();
                });
              }
              break;
            default:
              break;
          }
        },
      )
    );
  }
}