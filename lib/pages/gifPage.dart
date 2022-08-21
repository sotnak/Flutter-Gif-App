import 'package:flutter/material.dart';
import 'package:nsfw_flutter/utils/arrayWindow.dart';
import 'package:nsfw_flutter/widgets/gifBar.dart';
import 'package:nsfw_flutter/widgets/highlightedText.dart';
import 'package:nsfw_flutter/api.dart';
import 'package:nsfw_flutter/utils/tag.dart';
import 'categoryPage.dart';
import '../utils/gif.dart';

class GifPage extends StatefulWidget {
  final int index;
  final Tag tag;
  final ArrayWindow<Gif> arrW;

  const GifPage({Key? key, required this.index, required this.tag, required this.arrW}) : super(key: key);

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {

  late ArrayWindow<Gif> arrW;
  bool isTimeLimited = false;
  int globalIndex = 0;

  void fetchGifs ({required WindowMovementDirection direction}){
    Map<String, int> hint = arrW.getHint(direction);

    if( !hint.containsKey('limit') || !hint.containsKey('skip')){
      throw Exception('limit/skip hint failed');
    }

    arrW.setFutureArray(
      future: fetchGifsByTag(tag: widget.tag.name, limit: hint['limit']!, skip: hint['skip']!),
      direction: direction,
    );
  }

  void restartLimiter() {
    isTimeLimited = true;
    Future.delayed(const Duration(milliseconds: 500)).then((value) => {isTimeLimited = false});
  }

  void clearImageCache(){
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  void nextGif(){
    if(globalIndex+1<widget.tag.count){
                
      setState(() {
        globalIndex++;
      });

      if(arrW.getStatus(globalIndex) == ArrayWindowStatus.front){
        setState(() {
          fetchGifs(direction: WindowMovementDirection.front);
        });
      }
    }
  }

  void prevGif(){
    if(globalIndex > 0){
                
      setState(() {
        globalIndex--;
      });

      if(arrW.getStatus(globalIndex) == ArrayWindowStatus.back){
        setState(() {
          fetchGifs(direction: WindowMovementDirection.back);
        });
      }
    }
  }

  @override
  void initState() {
    globalIndex = widget.index;

    arrW = widget.arrW;

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
      appBar: GifBar(
        futureGifs: arrW.futureArray,
        index: globalIndex,
        tagName: widget.tag.name,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder<List<Gif>>(
          future: arrW.futureArray,
          builder: ((context, snapshot) {
            if(snapshot.hasData){

              return( Stack( children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Center( 
                  child: Hero (
                    tag: arrW[globalIndex].url,
                    child: Image.network(arrW[globalIndex].url,
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
                  )
                ),
                HighlightedText(
                  text: '[$globalIndex] ${arrW[globalIndex].title}'
                ),
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
              prevGif();
              break;
            case 1:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (_)=> CategoryPage(tag: widget.tag, index: globalIndex, arrW: ArrayWindow.from(arrW)),
                      ),
                    );
              break;
            case 2:
              nextGif();
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