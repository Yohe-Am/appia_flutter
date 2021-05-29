import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appia/blocs/authentication/authentication.dart';

class IntroPage extends StatelessWidget {
  static const routeName = 'intro';

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<UserAuthenticationBloc>(context);
    return Scaffold(
      body: Stack(children: [
        FullscreenSliderDemo(),
        Positioned(
          bottom: 0.0,
          left: 10.0,
          right: 10.0,
          height: 180,
          child: Card(
            elevation: 4.0,
            shadowColor: Theme.of(context).accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "OffTime",
                  style: Theme.of(context).textTheme.headline1,
                ),
                Text("Take a break from your phone, use OffTime!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyElevatedButton(
                      title: "Login",
                      navigation: true,
                      myOnPressed: () {},
                    ),
                    MyElevatedButton(
                      title: "Sign Up",
                      navigation: true,
                      myOnPressed: () {},
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class MyElevatedButton extends StatelessWidget {
  final String title;
  final Function() myOnPressed;
  final bool navigation;

  MyElevatedButton(
      {required this.title,
      required this.myOnPressed,
      required this.navigation});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 55,
      child: ElevatedButton(
        child: Text(title, style: Theme.of(context).textTheme.button),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        onPressed: navigation
            ? () => Navigator.pushNamed(context, title)
            : myOnPressed,
      ),
    );
  }
}

class FullscreenSliderDemo extends StatelessWidget {
  final List<String> imgList = [
    'assets/images/clock.jpg',
    'assets/images/phone.jpg',
    'assets/images/people.jpg'
  ];
  final List<String> textList = [
    "Keep track of your actions",
    "Detach from your phone",
    "Interact with people"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;

          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 2),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeIn,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              // autoPlay: false,
            ),
            items: imgList
                .map((item) => Container(
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item,
                              fit: BoxFit.scaleDown,
                              height: height * 0.4,
                            ),
                            Text(
                              textList[imgList.indexOf(item)],
                            ),
                          ],
                        )),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
