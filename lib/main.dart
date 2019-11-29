// Flutter code sample for

// This example shows a [Form] with one [TextFormField] and a [RaisedButton]. A
// [GlobalKey] is used here to identify the [Form] and validate input.

import 'package:flutter/material.dart';
import 'package:login_test2/inicio.dart';
import 'package:login_test2/registro_social_media.dart';
import 'package:login_test2/sign_in.dart';
import 'package:login_test2/splash.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      routes: {
        '/': (BuildContext context)=>Splash(),
        '/signin': (BuildContext context)=>SignIn(),
        '/inicio': (BuildContext context)=>Inicio(),
        '/registro-social-media':(BuildContext context)=>RegistroSocialMedia(),
      },
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);
  bool estado = false;
  String correo, contra;
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  
  @override
  Widget build(BuildContext context) {
    
  }
}