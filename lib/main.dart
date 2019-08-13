import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoggedIn = false;
  var profileData;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Facebook Login"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () => facebookLogin.isLoggedIn
                  .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
            ),
          ],
        ),
        body: Container(
          child: Center(
            child: isLoggedIn
                ? _displayUserData(profileData)
                : _displayLoginButton(),
          ),
        ),
      ),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult
                .accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture']['data']['url'],
              ),
            ),
          ),
        ),
        SizedBox(height: 28.0),
        Text(
          "Logged in as: ${profileData['name']}",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }

  _displayLoginButton() {
    return RaisedButton(
      child: Text("Login with Facebook"),
      onPressed: () => initiateFacebookLogin(),
    );
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    print("Logged out");
  }
}
