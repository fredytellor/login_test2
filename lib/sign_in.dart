import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_test2/registro.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './models/user.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final Firestore db = Firestore.instance;
    String msgTxt = '';
    String correo, contra;
    User usuario;

    Future<String> signIn(String email, String password) async {
      try {
        AuthResult result = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print(result.user.uid);

        if (result.user.uid != null) {
          db
              .collection('usuarios')
              .document(result.user.uid)
              .get()
              .then((data) {
            print(data.data);
            final String auxImgUrl = data.data['profile_pic'];
            usuario = new User(
                nombre: data.data['nombre'],
                apellido: data.data['apellido'],
                imgUrl: auxImgUrl);
            Navigator.of(context)
                .pushReplacementNamed('/inicio', arguments: usuario);
          });
        } else {
          setState(() {
            msgTxt = 'Usuario y/o contraseña erroneos';
            print(msgTxt);
          });
        }
      } catch (error) {
        if (error.code == "ERROR_USER_NOT_FOUND") {
          setState(() {
            msgTxt = "El usuario no existe.";
            print(msgTxt);
          });
        } else if (error.code == "ERROR_WRONG_PASSWORD") {
          setState(() {
            msgTxt = "La contraseña no es válida.";
            print(msgTxt);
          });
        } else if (error.code == "ERROR_USER_DISABLED") {
          setState(() {
            msgTxt = "El usuario está deshabilitado.";
            print(msgTxt);
          });
        }
      }
    }

    Future<FacebookLoginResult> _handleFBSignIn() async {
      FacebookLogin facebookLogin = FacebookLogin();
      FacebookLoginResult facebookLoginResult =
          await facebookLogin.logIn(['email']);
      //await facebookLogin.logInWithReadPermissions(['email']);
      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.cancelledByUser:
          print("Cancelled");
          break;
        case FacebookLoginStatus.error:
          print("error");
          break;
        case FacebookLoginStatus.loggedIn:
          print("Logged In");
          break;
      }
      return facebookLoginResult;
    }

    Future<GoogleSignInAccount> _handleGoogleSignIn() async {
      /*GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly'
      ]);*/
      GoogleSignIn googleSignIn = new GoogleSignIn();

      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      return googleSignInAccount;
    }

    Future<AuthResult> signInWithGoogle() async {
      GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = await _auth.signInWithCredential(credential);
      print("signed in " + user.user.displayName);

      return user;
    }

    Future<AuthResult> _handleSignIn(String type) async {
      switch (type) {
        case "FB":
          FacebookLoginResult facebookLoginResult = await _handleFBSignIn();
          final accessToken = facebookLoginResult.accessToken.token;
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
            final facebookAuthCred =
                FacebookAuthProvider.getCredential(accessToken: accessToken);
            final user = await _auth.signInWithCredential(facebookAuthCred);
            //print("User : " + user.displayName);
            print("User : " + user.user.uid);
            return user;
          } else
            return null;
          break;
        case "G":
          try {
            AuthResult user = await signInWithGoogle();

            /*GoogleSignInAccount googleSignInAccount =
                await _handleGoogleSignIn();
            final googleAuth = await googleSignInAccount.authentication;
            final googleAuthCred = GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken);
            final user = await _auth.signInWithCredential(googleAuthCred);
            //print("User : " + user.displayName);*/
            return user;
          } catch (error) {
            print(error);
            return error;
          }
      }
      return null;
    }

    void initiateSignIn(String type) async {
      /*   User user;
      _handleSignIn(type).then((result) {
        if (result != null) {
            Firestore.instance
                .collection('usuarios')
                .document(result.user.uid)
                .get()
                .then((value) {
              if (value != null) {
                user = new User(
                  nombre: value.data['nombre'],
                  apellido: value.data['apellido'],
                  imgUrl: value.data['profile_pic'],
                );
                setState(() {
                  Navigator.of(context)
                      .pushReplacementNamed('/inicio', arguments: user);
                });
              } else {
                setState(() {
                  Navigator.of(context).pushReplacementNamed(
                      '/registro-social-media',
                      arguments: result);
                });
              }
            });    
        }
      });*/

      User user;
      _handleSignIn(type).then((result) async {
        if (result != null) {
          DocumentSnapshot value = await Firestore.instance
              .collection('usuarios')
              .document(result.user.uid)
              .get();

           if(value.exists){
             user = new User(
                  nombre: value.data['nombre'],
                  apellido: value.data['apellido'],
                  imgUrl: value.data['profile_pic'],
                );
                setState(() {
                  Navigator.of(context)
                      .pushReplacementNamed('/inicio', arguments: user);
                });
           }else{
             setState(() {
                  Navigator.of(context)
                      .pushReplacementNamed('/registro-social-media', arguments: result);
                });
           }   
        }
      });
    }

    Container _buildFacebookLoginButton() {
      return Container(
        margin: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
        child: ButtonTheme(
          height: 48,
          child: RaisedButton(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onPressed: () {
                initiateSignIn("FB");
              },
              color: Color.fromRGBO(27, 76, 213, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              textColor: Colors.white,
              child: Text(
                "Connect with Facebook",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
        ),
      );
    }

    Container _buildGoogleLoginButton() {
      return Container(
        margin: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
        child: ButtonTheme(
          height: 48,
          child: RaisedButton(
              onPressed: () {
                initiateSignIn("G");
              },
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              textColor: Color.fromRGBO(122, 122, 122, 1),
              child: Text("Connect with Google",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: SingleChildScrollView(
              child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Correo electronico',
                    ),
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
                              .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      correo = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      contra = value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            signIn(correo, contra);
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(msgTxt),
            SizedBox(
              height: 10,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return Registro();
                }));
              },
              child: Text('Registrarse'),
            ),
            SizedBox(
              height: 10,
            ),
            _buildFacebookLoginButton(),
            _buildGoogleLoginButton(),
          ],
        ),
      ),
    );
  }
}
