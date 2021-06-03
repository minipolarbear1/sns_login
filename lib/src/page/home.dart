import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_login/src/page/login.dart';

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (!snapshot.hasData) {
              return LoginWidget();
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "${snapshot.data.displayName ?? snapshot.data.email}님 환영합니다."),
                    FlatButton(
                      onPressed: FirebaseAuth.instance.signOut,
                      child: Text("Log Out"),
                      color: Colors.grey.withOpacity(0.3),
                    )
                  ],
                ),
              );
            }
          }),
    );
  }
}
