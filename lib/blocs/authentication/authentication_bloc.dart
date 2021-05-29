import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:appia/data_provider/data_provider.dart';
import 'package:appia/repository/repository.dart';
import 'package:appia/blocs/authentication/authentication.dart';

class UserAuthenticationBloc
    extends Bloc<UserAuthenticationEvent, UserAuthenticationState> {
  final UserRepository userRepository;

  UserAuthenticationBloc({required this.userRepository})
      : assert(userRepository != null),
        super(UserNotAuthenticated());

  factory UserAuthenticationBloc.checkIfLoggedIn(
          {required UserRepository userRepository}) =>
      UserAuthenticationBloc(userRepository: userRepository)..add(IsLoggedIn());

  Stream<UserAuthenticationState> mapEventToState(
      UserAuthenticationEvent event) async* {
    if (event is SignUpRequested) {
      yield* _mapSignUpRequestedToState(event);
    } else if (event is LoginRequested) {
      yield* _mapLoginRequestedToState(event);
    } else if (event is LogoutRequested) {
      yield* _mapLogoutRequestedToState(event);
    } else if (event is IsLoggedIn) {
      yield* _mapIsLoggedInToState(event);
    }
  }

  Stream<UserAuthenticationState> _mapIsLoggedInToState(
      IsLoggedIn event) async* {
    try {
      final sharedData = await userRepository.getPreferences();
      if (sharedData == null) {
        yield UserNotAuthenticated();
        return;
      }
      //  final refreshedToken=await userRepository.refreshToken(sharedData[1]);

      try {
        final user = await userRepository.getUser(sharedData[0], sharedData[1]);
        yield UserAuthenticationSuccess(user: user);
      } catch (e) {
        if (e is SocketException) {
          yield UserOffLine(sharedData[0], sharedData[1]);
        } else if (e is NoUserException) {
          yield UserAuthenticationFailure(errMessage: e.toString());
        } else {
          yield UserAuthenticationFailure(errMessage: e.toString());
        }
      }
    } catch (err) {
      yield UserAuthenticationFailure(errMessage: err.toString());
    }
  }

  Stream<UserAuthenticationState> _mapSignUpRequestedToState(
      SignUpRequested event) async* {
    yield UserAuthenticationWaiting();
    try {
      final user = await userRepository.createUser(event.userInput);

      yield UserAuthenticationSuccess(user: user);
    } catch (err) {
      yield UserAuthenticationFailure(errMessage: err.toString());
    }
  }

  Stream<UserAuthenticationState> _mapLoginRequestedToState(
      LoginRequested event) async* {
    try {
      print(event.userInput);
      final user = await userRepository.loginUser(event.userInput);
      print(event.userInput.password);
      print("checking");
      yield UserAuthenticationSuccess(user: user);
    } catch (err) {
      yield UserAuthenticationFailure(errMessage: err.toString());
    }
  }

  Stream<UserAuthenticationState> _mapLogoutRequestedToState(
      LogoutRequested event) async* {
    yield UserAuthenticationWaiting();
    try {
      await userRepository.logoutUser();
      yield UserNotAuthenticated();
    } catch (err) {
      yield UserAuthenticationFailure(errMessage: err.toString());
    }
  }
}
