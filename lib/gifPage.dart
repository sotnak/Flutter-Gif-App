import 'package:flutter/material.dart';
import 'package:nsfw_flutter/mongo.dart';
import 'package:nsfw_flutter/tag.dart';
import 'categoryPage.dart';
import 'gif.dart';

const int windowSize = 32;

class GifPage extends StatefulWidget {
  final int index;
  final Tag tag;

  const GifPage({Key? key, required this.index, required this.tag}) : super(key: key);

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {

  late Future<List<Gif>> futureGifs;
  bool isTimeLimited = false;
  int index = 0;
  int chunk = 0;

  int getGlobalIndex(){
    return (index + chunk * windowSize * (3/8)).floor();
  }

  void fetchGifs ({bool moveIndex = true}){
    int skip = ( chunk * windowSize * (3/8) ).floor();

    futureGifs = fetchGifsByTag(tag: widget.tag.name, limit: windowSize, skip: skip);
    if(moveIndex){
      futureGifs.then( (value) => {
        if( index >= windowSize * (1/2) ){
          index = (index - windowSize * (3/8)).floor()
        }
        else{
          index = (index + windowSize * (3/8)).floor()
        },
        
        //print('fetched'),
        //print({'globalIndex': getGlobalIndex(), 'index': index, 'chunk':chunk}),
      });
    }
  }

  void restartLimiter() {
    isTimeLimited = true;
    Future.delayed(const Duration(milliseconds: 500)).then((value) => {isTimeLimited = false});
  }

  void clearImageCache(){
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  void initState() {
    index = widget.index;

    while(index >= windowSize * 7/8){
      chunk++;
      index = (index - windowSize * (3/8)).floor();
    }

    fetchGifs(moveIndex: false);
    restartLimiter();
    super.initState();
  }

  @override
  void dispose() {
    clearImageCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag.name),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder<List<Gif>>(
          future: futureGifs,
          builder: ((context, snapshot) {
            if(snapshot.hasData){
              List<Gif> gifs = snapshot.data ?? [];

              return( Stack( children: [
                Hero (
                  tag: gifs[index].url,
                    child: Image.network(gifs[index].url,
                      scale: 0.5,
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                
                        return Center(
                          child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                            : null,
                          ),
                        );
                      }
                    ),
                ),
                Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      '[${getGlobalIndex()}] ${gifs[index].title}',
                      style: TextStyle(
                        fontSize: 20,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = Colors.black,
                      ),
                    ),
                    // Solid text as fill.
                    Text(
                      '[${getGlobalIndex()}] ${gifs[index].title}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ]));
            }
            else if (snapshot.hasError) {
              throw {snapshot.error};
              //return Text("${snapshot.error}");
            }
              // By default show a loading spinner.
            return const CircularProgressIndicator();
          }
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.navigate_before),
            label: 'prev',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.panorama_vertical),
            label: 'list',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigate_next),
            label: 'next',
          )
        ],
        onTap: (button){
          
          if(isTimeLimited){
            return;
          }

          restartLimiter();

          switch(button){
            case 0:
              if(getGlobalIndex() > 0){
                
                setState(() {
                  index--;
                });

                if(index <= windowSize * 1/8 && chunk > 0){
                  setState(() {
                    chunk--;
                    fetchGifs();
                  });
                }
              }
              break;
            case 1:
              Navigator.pop(context);
              Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (_)=> CategoryPage(tag: widget.tag, index: getGlobalIndex()),
                      ),
                    );
              break;
            case 2:
              if(getGlobalIndex()+1<widget.tag.count){
                
                setState(() {
                  index++;
                });

                if(index >= windowSize * 7/8){
                  setState(() {
                    chunk++;
                    fetchGifs();
                  });
                }
              }
              break;
            default:
              break;
          }
          //print({'globalIndex': getGlobalIndex(), 'index': index, 'chunk':chunk});
        },
      )
    );
  }
}