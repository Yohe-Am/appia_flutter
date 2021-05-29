import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appia/off_time.dart';

import 'package:email_validator/email_validator.dart';

class SignUpPage extends StatelessWidget {
  static const routeName = 'Sign Up';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(30.0),
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "Sign Up",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              SignUpPageForm(),
              Text(
                "Already have an account?",
                style: Theme.of(context).textTheme.headline2,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, LoginPage.routeName);
                  },
                  child: Text(
                    "Login",
                    style: Theme.of(context).textTheme.headline4,
                  ))
            ],
          )),
    );
  }
}

class SignUpPageForm extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPageForm> {
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
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  if (authState is UserAuthenticationFailure)
                    Text("Wrong credentials ${authState.errMessage}"),
                  TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Username';
                        } else if (value.length < 5) {
                          return 'Username should be atleast 5 characters';
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Email';
                        } else if (!EmailValidator.validate(value)) {
                          return 'Enter proper email address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        icon: Icon(
                          Icons.email_outlined,
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
                          this._user["email"] = value;
                        });
                      }),
                  TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter password';
                        } else if (value.length < 8) {
                          return 'Password should be atleast 8 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        icon: Icon(
                          Icons.lock_outline,
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
                          this._user["password"] = value;
                        });
                      }),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: MyElevatedButton(
                          title: "Sign Up",
                          myOnPressed: () {
                            final form = _formKey.currentState;
                            if (form!.validate()) {
                              form.save();
                              final UserAuthenticationEvent event =
                                  SignUpRequested(
                                      userInput: UserInput(
                                          username: _user["username"],
                                          password: _user["password"],
                                          email: _user["email"]));

                              BlocProvider.of<UserAuthenticationBloc>(context)
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
      ),
    );
  }
}
