import 'package:flutter/material.dart';
import 'package:nsfw_flutter/gifPage.dart';
import 'tag.dart';
import 'mongo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Tag>> futureTags;

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Flutter NSFW');

  void submit(String str){
    fetchCategories(query: str);
  }

  fetchCategories({String query=''}){
    setState(() {
      if(query.isEmpty){
        futureTags = fetchTags();
      }
      else{
        futureTags = searchTags(query);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter NSFW Example',
      home: Scaffold(
        appBar: AppBar(
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
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration:const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'search for category',
                        ),
                        onSubmitted: (String value) {
                          if(value.isNotEmpty){
                            submit(value);
                          }
                        },
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Flutter NSFW');
                    submit('');
                  }
                });
              },
              icon: customIcon,
            )
          ],
        ),
        body: FutureBuilder <List<Tag>>(
          future: futureTags,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Tag> tags = snapshot.data ?? [];

              return ListView(
                scrollDirection: Axis.vertical,
                addAutomaticKeepAlives: false,
                children: tags.map((tag) => ListTile(
                  title: Text(tag.name),
                  subtitle: Text(tag.count.toString()),
                  onTap: (){
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (_)=> GifPage(index: 0, tag: tag),
                      ),
                    );
                  },
                )
                ).toList(),
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