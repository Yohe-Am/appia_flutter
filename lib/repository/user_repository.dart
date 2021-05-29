import 'dart:io';
import 'package:appia/data_provider/data_provider.dart';
import 'package:appia/models/models.dart';

class UserRepository {
  final UserDataProvider userDataProvider;
  UserRepository({required this.userDataProvider})
      // ignore: unnecessary_null_comparison
      : assert(userDataProvider != null);

  Future<User> createUser(UserInput userInput) async {
    await userDataProvider.createUser(userInput);
    String token = await userDataProvider.postToken(userInput);
    User user = await userDataProvider.getUser(userInput.username, token);
    await userDataProvider.addToSharedPreferences(user);
    return user;
  }

  Future<User> loginUser(UserInput userInput) async {
    String token = await userDataProvider.postToken(userInput);
    User user = await userDataProvider.getUser(userInput.username, token);

    await userDataProvider.addToSharedPreferences(user);
    return user;
  }

  Future<User> getUser(String username, String token) async {
    return await userDataProvider.getUser(username, token);
  }

  Future<User> updateUser(User user, UserUpdateInput userUpdateInput) async {
    return await userDataProvider.updateUser(user, userUpdateInput);
  }

  Future<void> deleteUser(User user) async {
    await userDataProvider.deleteUser(user);
    await userDataProvider.deletePreferences();
  }

  Future<String> putPicture(User user, File file) async {
    return await userDataProvider.putPicture(user, file);
  }

  Future<String> refreshToken(String token) async {
    return await userDataProvider.refreshToken(token);
  }

  Future<List<String>> getPreferences() async {
    return await userDataProvider.getSharedPreferences();
  }

  Future<void> logoutUser() async {
    await userDataProvider.clearAuthInfoFromSharedPreferences();
    await userDataProvider.deletePreferences();
  }
}
