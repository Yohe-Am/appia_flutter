import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  static const routeName = 'Search';
  SearchList ts = new SearchList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(hintText: 'Search'),
        ),
      ),
      body: ListView.builder(
          itemCount: ts.searchList.length,
          itemBuilder: (context, index) {
            final item = ts.searchList[index];
            return ListTile(
              title: Text(item.userHeader),
              subtitle: Text(item.username),
            );
          }),
    );
  }
}

class SearchList {
  final List<SearchItem> searchList =
      List<SearchItem>.generate(10, (i) => SearchItem('User $i', 'U'));
}

class SearchItem {
  final String username;
  final String userHeader;

  SearchItem(this.username, this.userHeader);
}
