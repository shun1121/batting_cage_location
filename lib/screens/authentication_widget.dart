import 'package:batting_cage_location/screens/my_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({super.key});

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top:32.0),
                child: ElevatedButton(
                  child: const Text('登録'),
                  onPressed: () async {
                    try {
                      final User? user = (await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _email, password: _password))
                          .user;
                      if (user != null)
                        print("ユーザ登録しました ${user.email} , ${user.uid}");
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyWidget()),
                        );
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ),
              ElevatedButton(
                child: const Text('ログイン'),
                onPressed: () async {
                  try {
                    final User? user = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _email, password: _password))
                        .user;
                    if (user != null)
                      print("ログインしました　${user.email} , ${user.uid}");
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyWidget()),
                      );
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              ElevatedButton(
                  child: const Text('パスワードリセット'),
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _email);
                      print("パスワードリセット用のメールを送信しました");
                    } catch (e) {
                      print(e);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}