import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_test2/models/user.dart';
import 'inicio.dart';
import 'main.dart';

class Splash extends StatefulWidget {
  final db = Firestore.instance;
  @override
  //_SplashState createState() => _SplashState();
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  initState() {
    super.initState();
    // FirebaseAuth.instance.signOut();
    // Add listeners to this class
    validarUsuario();
  }

  Future<DocumentSnapshot> obtenerDatos(FirebaseUser user) async {
    User usuario;
    await widget.db.collection('usuarios').document(user.uid).get().then((doc) {
      //print(data['nombre']);
      print(doc.data['nombre']);
      String auxImgUrl = doc.data['profile_pic'];
      usuario = new User(
          nombre: doc.data['nombre'],
          apellido: doc.data['apellido'],
          imgUrl: auxImgUrl);

      setState(() {
        Navigator.of(context)
            .pushReplacementNamed('/inicio', arguments: usuario);
      });
    });

    //return widget.doc
  }

  Future<Widget> validarUsuario() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      print('true');
      obtenerDatos(user);
      //return true;

    } else {
      print('false');
      setState(() {
        Navigator.of(context).pushReplacementNamed('/signin');
      });

      //return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
