import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:appia/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoUserException implements Exception {}

class UserDataProvider {
  final _baseUrl = "http://192.168.43.41:8080";
  final http.Client httpClient;

  UserDataProvider({required this.httpClient});
  //TODO 409 CONFLICTS 422 UNPROCESSABLE Password
  Future<User> createUser(UserInput userInput) async {
    final http.Response response = await httpClient.put(
      Uri.parse('$_baseUrl/users/${userInput.username}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'password': userInput.password,
        'email': userInput.email,
      }),
    );
    //TODO 409 CONFLICT
    if (response.statusCode == 409) {
      throw Exception(
          'User of this ${jsonDecode(response.body)['field']} already exists');
    } else if (response.statusCode != 200) {
      throw Exception(
          'Failed to create user User: code ${response.statusCode}');
    }
    return User.fromJson(jsonDecode(response.body));
  }

  Future<String> postToken(UserInput userInput) async {
    print("${userInput.username}");
    final response = await httpClient.post(
      Uri.parse("$_baseUrl/token-auth"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'password': userInput.password,
        'username': userInput.username,
      }),
    );
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body)['token'];
      case 403:
        throw Exception('Auth failed username or password incorrect.');
      default:
        throw Exception('Failed to auth user: code ${response.statusCode}');
    }
  }

  Future<User> getUser(String username, String token) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/users/$username'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + token,
          HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
        },
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        return User(
            username: user['username'],
            createdAt: DateTime.parse(user['createdAt']),
            updatedAt: DateTime.parse(user['updatedAt']),
            email: user['email'],
            pictureURL: user['pictureURL'] == null ? null : user['pictureURL'],
            roomHistory: (user['roomHistory'] as List)
                .map((item) => item as String)
                .toList(),
            token: token);
      } else if (response.statusCode == 404) {
        throw new NoUserException();
      } else {
        throw Exception(
            'Failed to load User $username: code ${response.statusCode}');
      }
    } on SocketException {
      throw new SocketException("Socket error");
    }
  }

  Future<String> refreshToken(String token) async {
    final response = await httpClient.get(
      Uri.parse('$_baseUrl/token-auth-refresh'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer" + token,
        HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['auth_token'];
    } else {
      throw Exception('Failed to refresh token: code ${response.statusCode}');
    }
  }

  Future<User> updateUser(User user, UserUpdateInput userUpdateInput) async {
    print(user);
    print(userUpdateInput);

    final http.Response response = await httpClient.patch(
      Uri.parse('$_baseUrl/users/${user.username}'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer " + user.token,
        HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8"
      },
      body: jsonEncode(<String, dynamic>{
        'email': userUpdateInput.email,
        'password': userUpdateInput.password,
      }),
    );
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      return User.fromJson(user);
    } else {
      throw Exception(
          'Failed to update User: code ${response.statusCode} and ${response.body}');
    }
  }

  Future<void> deleteUser(User user) async {
    final response = await httpClient.delete(
      Uri.parse('$_baseUrl/users/${user.username}'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer " + user.token,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete User: code ${response.statusCode}');
    }
  }

  Future<void> deletePreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<String> putPicture(User user, File file) async {
    var uri = Uri.parse(_baseUrl + "/users" + user.username + "/picture");
    var request = http.MultipartRequest('PUT', uri)
      ..files.add(await http.MultipartFile.fromPath('image', file.path,
          contentType: MediaType('image', lookupMimeType(file.path))));
    request.headers['authorization'] = "Bearer " + user.token;

    http.Response responseBody =
        await http.Response.fromStream(await request.send());
    if (responseBody.statusCode != 200) {
      throw Exception('Failed to put picture: code ${responseBody.statusCode}');
    }
    return jsonDecode(responseBody.body);
  }

  Future<void> addToSharedPreferences(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList("authInfo", [user.username, user.token]);
  }

  Future<List<String>> getSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> userAuth = sharedPreferences.getStringList("authInfo");
    print("userAuth: ${userAuth.toString()}");
    return userAuth;
  }

  Future<void> clearAuthInfoFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("authInfo");
  }
}
