import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './models/user.dart';

class RegistroSocialMedia extends StatefulWidget {
  @override
  _RegistroSocialMediaState createState() => _RegistroSocialMediaState();
}

class _RegistroSocialMediaState extends State<RegistroSocialMedia> {

  @override
 

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthResult socialMediaUser = ModalRoute.of(context).settings.arguments;

    void _onContinue() {
      var newUserData = {
        'nombre': nameController.text,
        'apellido': lastNameController.text,
        'profile_pic': socialMediaUser.user.photoUrl
      };

      User newUser = new User(
        nombre: nameController.text,
        apellido: lastNameController.text,
        imgUrl: socialMediaUser.user.photoUrl,
      );

      Firestore.instance
          .collection('usuarios')
          .document(socialMediaUser.user.uid)
          .setData(newUserData);

      Navigator.of(context).pushReplacementNamed('/inicio', arguments: newUser);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro por Social Media'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                height: 200,
                child: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Image.network(socialMediaUser.user.photoUrl),
                ),
              ),
              Container(
                width: 200,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'nombre',
                        labelText: socialMediaUser.user.displayName,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        hintText: 'apellido',
                        labelText: socialMediaUser.user.displayName,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onContinue,
        child: Icon(Icons.check_circle),
        tooltip: 'Aceptar y continuar',
      ),
    );
  }
}
