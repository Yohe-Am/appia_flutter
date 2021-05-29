import 'package:appia/screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appia/off_time.dart';
import 'package:appia/screens/screens.dart';

class LoginPage extends StatelessWidget {
  static const routeName = 'Login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30.0),
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "Login",
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              LoginPageForm(),
              Text(
                "Don't have an account?",
                style: Theme.of(context).textTheme.headline2,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, SignUpPage.routeName);
                  },
                  child: Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.headline4,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPageForm extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPageForm> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _user = {};

  @override
  Widget build(BuildContext ctx) {
    return Container(
      color: Theme.of(ctx).primaryColor,
      child: BlocConsumer<UserAuthenticationBloc, UserAuthenticationState>(
        listener: (ctx, state) {
          if (state is UserAuthenticationSuccess)
            Navigator.of(ctx)
                .pushNamedAndRemoveUntil(HomePage.routeName, (route) => false);
        },
        builder: (ctx, authState) => Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (authState is UserAuthenticationFailure)
                  Text("Wrong credentials"),
                TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Username';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Userame',
                      icon: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: Theme.of(context).accentColor,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).accentColor),
                      ),
                    ),
                    onSaved: (value) {
                      setState(() {
                        this._user["username"] = value;
                      });
                    }),
                TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.lock_outline,
                          size: 30, color: Theme.of(context).accentColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).accentColor),
                      ),
                    ),
                    onSaved: (value) {
                      setState(() {
                        this._user["password"] = value;
                      });
                    }),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: MyElevatedButton(
                        title: "Login",
                        myOnPressed: () {
                          final form = _formKey.currentState;
                          if (form!.validate()) {
                            form.save();
                            final UserAuthenticationEvent event =
                                LoginRequested(
                                    userInput: UserInput(
                                        username: _user["username"],
                                        password: _user["password"],
                                        email: ''));
                            print(_user);
                            BlocProvider.of<UserAuthenticationBloc>(ctx)
                                .add(event);
                          }
                        },
                        navigation: false,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
