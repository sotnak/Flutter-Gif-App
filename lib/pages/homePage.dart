import 'package:flutter/material.dart';
import 'package:nsfw_flutter/widgets/searchBar.dart';
import 'categoryPage.dart';
import '../utils/tag.dart';
import '../mongo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Tag>> futureTags;

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
        appBar: SearchBar(
          submit: submit,
          title: 'Flutter NSFW',
          label: 'search for category'
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
                        builder: (_)=> CategoryPage(tag: tag, index: 0),
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