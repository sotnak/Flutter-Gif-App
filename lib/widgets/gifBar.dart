import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/gif.dart';

class GifBar extends StatelessWidget implements PreferredSize {
  final Future<List<Gif>> futureGifs;
  final int index;
  final String tagName;

  GifBar({Key? key, required this.futureGifs, required this.index, required this.tagName}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  // TODO: implement child
  Widget get child => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(tagName),
      backgroundColor: Colors.blue,
      actions: [
        FutureBuilder<List<Gif>>(
          future: futureGifs,
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List<Gif> gifs = snapshot.data ?? [];
              
              return(
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: gifs[index].url)).then((_){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Url copied to clipboard")));
                    });
                  },
                  icon: const Icon(Icons.share),
                )
              );
            }
            else{
              return(
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unable to copy url")));
                  },
                  icon: const Icon(Icons.share),
                )
              );
            }
          }
        )
      ],
    );
  }
}