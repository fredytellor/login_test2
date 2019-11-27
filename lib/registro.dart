import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Registro extends StatefulWidget {
  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();
  String correo, contra, nombre, apellido,edad,msgtxt;

  Future<String> _onsubmitted() async {
    String uid;
    Firestore db=Firestore.instance;
    AuthResult result =await _auth.createUserWithEmailAndPassword(email: correo,password: contra);
    uid=result.user.uid;

    var nuevo = {
      'nombre':nombre,
      'apellido':apellido,
      'edad':edad
    };
    db.collection('usuarios').document(uid).setData(nuevo);
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: SingleChildScrollView(
              child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Nombre',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Ingresa un nombre valido';
                  }
                },
                onSaved: (value) {
                  nombre = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Apellido',
                ),
                validator: (value) {
                  if (value.isEmpty ||
                      !RegExp(r'^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]+$')
                          .hasMatch(value)) {
                    return 'Ingresa un apellido valido';
                  }
                },
                onSaved: (value) {
                  apellido = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Edad',
                ),
                validator: (value) {
                  if (value.isEmpty ||
                      !RegExp(r'^[0-9]+$')
                          .hasMatch(value)) {
                    return 'Ingresa una edad valida';
                  }
                },
                onSaved: (value) {
                  edad = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.pinkAccent,
                    width: 4,
                  ),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'example@dominio.algo',
                  ),
                  validator: (value) {
                    if (value.isEmpty ||
                        !RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
                            .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  },
                  onSaved: (value) {
                    correo = value;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.pinkAccent,
                    width: 4,
                  ),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'contraseña de 6 caracteres',
                  ),
                  validator: (value) {
                    if (value.length < 6) {
                      return 'contraseña debe tener al menos 6 caracteres';
                    }
                  },
                  obscureText: true,
                  onSaved: (value) {
                    contra = value;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              //Radio(),
              SizedBox(
                height: 10,
              ),
              Center(
                child: RaisedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _onsubmitted();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
