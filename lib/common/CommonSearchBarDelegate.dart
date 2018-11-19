import 'package:flutter/material.dart';

typedef BuildSuggestions<String> = Widget Function(String query);
class CommonSearchBarDelegate<T> extends SearchDelegate<String> {
  BuildSuggestions buildSuggestionsPage;


  CommonSearchBarDelegate(this.buildSuggestionsPage);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return
      Container(
      width: 100.0,
      height: 100.0,
      child: Card(
        color: Colors.redAccent,
        child: Center(
          child: Text(query),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSuggestionsPage(query);
  }

}