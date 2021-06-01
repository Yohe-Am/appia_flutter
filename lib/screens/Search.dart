import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../appia.dart';

class Search extends StatelessWidget {
  static const routeName = 'Search';
  SearchList ts = new SearchList();

  @override
  Widget build(BuildContext context) {
    final userDataProvider = UserDataProvider(httpClient: http.Client());
    final userRepository = UserRepository(userDataProvider: userDataProvider);
    final searchBloc = UserBloc(userRepository);
    return BlocProvider(
      create: (context) => searchBloc..add(GetAllUsers()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left_outlined),
            onPressed: () {},
          ),
          title: TextField(
            decoration: InputDecoration(hintText: 'Search'),
            onChanged: (username) {
              if (username.length > 0) {
                searchBloc.add(SearchUserRequested(username));
              }
            },
          ),
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) => state is UserLoadSuccess
              ? ListView.builder(
                  itemCount: ts.searchList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(state.user.username.substring(0, 1)),
                      subtitle: Text(state.user.username),
                    );
                  })
              : Text(''),
        ),
      ),
    );
  }
}

class SearchList {
  final List<SearchItem> searchList =
      List<SearchItem>.generate(10, (i) => SearchItem('User $i'));
}

class SearchItem {
  final String username;

  SearchItem(this.username);
}
