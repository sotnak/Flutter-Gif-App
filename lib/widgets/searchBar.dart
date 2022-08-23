import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget with PreferredSizeWidget {
  final Function submit;
  final Function cancel;
  final String title;
  final String label;

  const SearchBar({Key? key, required this.submit, required this.cancel, required this.title, required this.label}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _SearchBarState extends State<SearchBar> {

  bool isSearching = false;
  String query='';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late Widget customSearchBar;
    
    if(isSearching){
      customSearchBar = ListTile(
        leading: IconButton(
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            widget.cancel();
            setState(() {
              isSearching = false;
            });
          },
        ),
        title: TextField(
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration:const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'search for category',
          ),
          onSubmitted: (String value) {
            if(value.isNotEmpty){
              widget.submit(value);
            }
          },
          onChanged: (String value) {
            query = value;
          },
        ),
      );
    } else {
      customSearchBar = Text(widget.title);
    }

    return (AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (isSearching) {
                  if(query.isNotEmpty){
                    widget.submit(query);
                  }
                } else {
                  isSearching = true;
                }
              });
            },
            icon: const Icon(Icons.search),
          )
        ],
      )
    );
  }
}