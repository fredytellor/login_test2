import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'models/user.dart';

class Inicio extends StatefulWidget {
  String uid;
  var profilePic;

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  StorageReference storageReference;
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  File _image;
  StorageUploadTask upload;
  StreamSubscription<StorageTaskEvent> streamSubscription;

  @override
  void initState() {
    super.initState();
    setState(() {
      getUid();
    });
  }

  Future updateURLPic(String url) async {
    Firestore db = Firestore.instance;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uid = user.uid;
    var nuevo = {
      'imgURL': url,
    };
    db.collection('usuarios').document(uid).updateData(nuevo);
    print('Update imgUrl completado');
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future getUid() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      widget.uid = user.uid;
    });
    return widget.uid;
  }

  @override
  Widget build(BuildContext context) {
    //final Map<String, dynamic> data = ModalRoute.of(context).settings.arguments;
    final User data = ModalRoute.of(context).settings.arguments;

    String mostrarTexto(String texto) {
      switch (texto) {
        case 'nombre':
          return data.nombre;
          break;
        case 'apellido':
          return data.apellido;
          break;
        case 'imgUrl':
          return data.imgUrl;
      }
    }

    Future<String> updateData(
        String nombre, String apellido, dynamic imgUrl) async {
      Firestore db = Firestore.instance;
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String uid = user.uid;
      var nuevo = {
        'nombre': nombre,
        'apellido': apellido,
        'profile_pic': imgUrl.toString(),
      };
      db.collection('usuarios').document(uid).updateData(nuevo);
      print('Update info completado');
    }

    Future<String> uploadPic() async {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String uid = user.uid;
      storageReference = FirebaseStorage().ref().child('/profile_pics/${uid}');
      upload = storageReference.putData(_image.readAsBytesSync());
      streamSubscription = upload.events.listen((event) {
        print('EVENT ${event.type}');
      });
      /*await upload.onComplete;
       widget.profilePic = storageReference.getDownloadURL();*/
      widget.profilePic = await (await upload.onComplete).ref.getDownloadURL();
      //updateURLPic(widget.profilePic);
      streamSubscription.cancel();
      print('update pic completado');
      updateData(
          nameController.text, lastNameController.text, widget.profilePic);
    }

    Widget imgWid() {
      if (_image != null) {
        return Image.file(_image);
      } else if (data.imgUrl != null) {
        return Image.network(data.imgUrl);
      } else {
        return Image.network(
          'https://www.thedayspring.com.pk/wp-content/uploads/2019/09/No-Image.png',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Loged in'),
      ),
      drawer: Drawer(
        child: Center(
          child: Text('Drawer!!'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 200,
                      child: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: imgWid(),
                        /* _image == null
                            ? Image.network(
                                'https://www.thedayspring.com.pk/wp-content/uploads/2019/09/No-Image.png',
                              )
                            : Image.file(_image),*/
                      ),
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
                            hintText: 'Nombre',
                            labelText: mostrarTexto('nombre'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            hintText: 'Apellido',
                            labelText: mostrarTexto('apellido'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('sign out'),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/signin');
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.save,
                        size: 35,
                      ),
                      onPressed: () {
                        uploadPic();
                      },
                      tooltip: 'Actualiza la informacion',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
