import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget with PreferredSizeWidget {
  final Function submit;
  final String title;
  final String label;

  const SearchBar({Key? key, required this.submit, required this.title, required this.label}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _SearchBarState extends State<SearchBar> {

  Icon customIcon = const Icon(Icons.search);
  late Widget customSearchBar;

  @override
  void initState() {
    customSearchBar = Text(widget.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
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
                    ),
                  );
                } else {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = Text(widget.title);
                  widget.submit('');
                }
              });
            },
            icon: customIcon,
          )
        ],
      )
    );
  }
}