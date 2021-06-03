import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//login
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LoginWidget extends StatelessWidget {
  const LoginWidget({Key key}) : super(key: key);

  //google login
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

//Apple login
  Future<UserCredential> signInWithApple() async {
    bool isAvailable = await SignInWithApple.isAvailable();
    if (isAvailable) {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: "com.test.sns.login.socialLogin.web",
            redirectUri: Uri.parse(
                "https://crystalline-careful-mockingbird.glitch.me/callbacks/sign_in_with_apple"),
          ));

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } else {
      final clientState = Uuid().v4();
      final url = Uri.https('appleid.apple.com', '/auth/authorize', {
        'response_type': 'code id_token',
        'client_id': "com.test.sns.login.socialLogin.web",
        'response_mode': 'form_post',
        'redirect_uri':
            'https://crystalline-careful-mockingbird.glitch.me/callbacks/apple/sign_in_with_apple',
        'scope': 'email name',
        'state': clientState,
      });

      final result = await FlutterWebAuth.authenticate(
          url: url.toString(), callbackUrlScheme: "applink");

      final body = Uri.parse(result).queryParameters;
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: body['id_token'],
        accessToken: body['code'],
      );
      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    }
  }

  //kakao Login
  Future<UserCredential> signInWithKakao() async {
    final clientState = Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code', //고정
      'client_id': "f46ef2fa51ca2734ba4d500bce338aa5",
      'response_mode': 'form_post',
      'redirect_uri':
          'https://crystalline-careful-mockingbird.glitch.me/callbacks/kakao/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");

    final body = Uri.parse(result).queryParameters;
    print(body);

    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code', //고정
      'client_id': "f46ef2fa51ca2734ba4d500bce338aa5",
      'redirect_uri':
          'https://crystalline-careful-mockingbird.glitch.me/callbacks/kakao/sign_in',
      "code": body['code'],
    });
    var response = await http.post(tokenUrl.toString());
    print('Response status: ${response.statusCode}');
    Map<String, dynamic> accessTokenResult = json.decode(response.body);
    var responseCustomToken = await http.post(
        "https://crystalline-careful-mockingbird.glitch.me/callbacks/kakao/token",
        body: {"accessToken": accessTokenResult['access_token']});

    return await FirebaseAuth.instance
        .signInWithCustomToken(responseCustomToken.body);
  }

  //naver Login
  Future<UserCredential> signInWithNaver() async {
    final clientState = Uuid().v4();
    final url = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
      'response_type': 'code', //고정
      'client_id': "b3NbZ6Q5AWca2vSm6s7D",
      'response_mode': 'form_post',
      'redirect_uri':
          'https://crystalline-careful-mockingbird.glitch.me/callbacks/naver/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");

    final body = Uri.parse(result).queryParameters;
    print(body);

    final tokenUrl = Uri.https('nid.naver.com', '/oauth2.0/token', {
      'grant_type': 'authorization_code', //고정
      'client_id': "b3NbZ6Q5AWca2vSm6s7D",
      "client_secret": 'uKsqSqKKW_',
      'state': clientState,
      "code": body['code'],
    });
    var response = await http.post(tokenUrl.toString());
    print('Response status: ${response.statusCode}');
    Map<String, dynamic> accessTokenResult = json.decode(response.body);
    var responseCustomToken = await http.post(
        "https://crystalline-careful-mockingbird.glitch.me/callbacks/naver/token",
        body: {"accessToken": accessTokenResult['access_token']});

    return await FirebaseAuth.instance
        .signInWithCustomToken(responseCustomToken.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SNS Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: signInWithGoogle,
              child: Text("Google Login"),
              color: Colors.grey.withOpacity(0.3),
            ),
            FlatButton(
              onPressed: signInWithApple,
              child: Text("Apple Login"),
              color: Colors.grey.withOpacity(0.3),
            ),
            FlatButton(
              onPressed: signInWithKakao,
              child: Text("Kakao Login"),
              color: Colors.grey.withOpacity(0.3),
            ),
            FlatButton(
              onPressed: signInWithNaver,
              child: Text("Naver Login"),
              color: Colors.grey.withOpacity(0.3),
            )
          ],
        ),
      ),
    );
  }
}
