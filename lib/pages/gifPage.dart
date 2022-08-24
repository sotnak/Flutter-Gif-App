import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsfw_flutter/utils/arrayWindow.dart';
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

  Widget navButton({required Icon icon, required Alignment alignment, void Function()? onTap}){
    return Align(
      alignment: alignment,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          //color: Colors.blue,
          width: MediaQuery.of(context).size.width/4,
          height: MediaQuery.of(context).size.height/2,
          child: icon,
        )
      )
    );
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

    Scaffold scaffold = Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder<List<Gif>>(
          future: arrW.futureArray,
          builder: ((context, snapshot) {
            if(snapshot.hasData){

              return( SafeArea(child: Stack( children: [
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
                      },
                      errorBuilder: (BuildContext context,Object error, StackTrace? stackTrace) {
                        return const Center(child: HighlightedText(text: 'Unable to load', alignment: Alignment.center));
                      },
                    ),
                  )
                ),
                HighlightedText(
                  text: '${arrW[globalIndex].tags}',
                  alignment: Alignment.bottomRight,
                ),
                Builder(builder:(context) {
                  if(globalIndex<1 || arrW.getInnerIndex(globalIndex)<1){
                    return Container();
                  }

                  return navButton(
                    icon: const Icon(Icons.navigate_before, color: Colors.white),
                    alignment: Alignment.centerLeft,
                    onTap: prevGif
                  );
                },),
                Builder(builder:(context) {
                  if(globalIndex>=widget.tag.count-1 || arrW.getInnerIndex(globalIndex)>=arrW.length-1){
                    return Container();
                  }

                  return navButton(
                    icon: const Icon(Icons.navigate_next, color: Colors.white),
                    alignment: Alignment.centerRight,
                    onTap: nextGif
                  );
                },),
                Align(alignment: Alignment.topRight ,child: IconButton(
                      onPressed: () {
                      Clipboard.setData(ClipboardData(text: arrW[globalIndex].url)).then((_){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Url copied to clipboard")));
                      });
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  HighlightedText(
                    text: '[$globalIndex] ${arrW[globalIndex].title}'
                  ),]
                ),
              ])));
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
    );

    return WillPopScope(
      child: scaffold,
      onWillPop: () async {

        if(globalIndex == widget.index){
          return true;
        }

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context, 
          MaterialPageRoute(
            builder: (_)=> CategoryPage(tag: widget.tag, index: globalIndex, arrW: ArrayWindow.from(arrW)),
          ),
        );
        
        return false;
      },);
  }
}