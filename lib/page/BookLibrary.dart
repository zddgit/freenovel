import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

///书库
class BookLibrary extends StatefulWidget {
  @override
  BookLibraryState createState() {
    return BookLibraryState();
  }
}

class BookLibraryState extends State<BookLibrary> {

  SearchBar searchBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: Text("书库"),
    );
  }
  @override
  void initState() {
    super.initState();
    searchBar = SearchBar(
      setState: setState,
      buildDefaultAppBar: (context) {
        return new AppBar(
            title: new Text('搜书名'),
            actions: [searchBar.getSearchAction(context)]);
      },
      inBar: true,
      onSubmitted:(value){
        setState(() {

        });
      },
    );
  }

}
