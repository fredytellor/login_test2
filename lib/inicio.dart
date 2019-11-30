import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'models/user.dart';
import './menu_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  double lat = 40.6643;
  double long = -73.9385;
  int _index = 0;
  GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng _mapPosition = LatLng(40.6643, -73.9385);
  TextEditingController mapTextController = TextEditingController();
  double distance;
  String _address;
  List<Placemark> placemark;
  LatLng posMarker=new LatLng(40.6643, -73.9385);
  bool mapInfo=false;

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
      var nuevo;
      if (widget.profilePic != null) {
        nuevo = {
          'nombre': nombre,
          'apellido': apellido,
          'profile_pic': imgUrl.toString(),
        };
      } else {
        nuevo = {
          'nombre': nombre,
          'apellido': apellido,
        };
      }
      db.collection('usuarios').document(uid).updateData(nuevo);
      print('Update info completado');
    }

    Future<String> uploadPic() async {
      if (_image != null) {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        String uid = user.uid;
        storageReference =
            FirebaseStorage().ref().child('/profile_pics/${uid}');
        upload = storageReference.putData(_image.readAsBytesSync());
        streamSubscription = upload.events.listen((event) {
          print('EVENT ${event.type}');
        });
        /*await upload.onComplete;
       widget.profilePic = storageReference.getDownloadURL();*/
        widget.profilePic =
            await (await upload.onComplete).ref.getDownloadURL();
        //updateURLPic(widget.profilePic);
        streamSubscription.cancel();
        print('update pic completado');
      }
      updateData(
          nameController.text, lastNameController.text, widget.profilePic);
    }

    Widget imgWid() {
      if (_image != null) {
        return Image.file(_image);
      } else if (data.imgUrl != null) {
        return Image.network(
          data.imgUrl,
        );
      } else {
        return Image.network(
          'https://www.thedayspring.com.pk/wp-content/uploads/2019/09/No-Image.png',
        );
      }
    }

    Future<Position> _getPosition() async {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((value) {
        setState(() {
          lat = value.latitude;
          long = value.longitude;
        });
      });
      return position;
    }

    void _getAddress(double lati, double longi) async {
      placemark = await Geolocator().placemarkFromCoordinates(lati, longi);

      _address = placemark[0].name.toString() +
          ',' +
          placemark[0].locality.toString() +
          ',' +
          placemark[0].postalCode.toString();
    }

    void _putMarker(LatLng pos) async {
      if (_markers.length == 1) {
        _markers.clear();
      }

      setState(() {
        _getAddress(_mapPosition.latitude, _mapPosition.longitude);
        _mapPosition = pos;
        _markers.add(
          Marker(
            markerId: MarkerId(_mapPosition.toString()),
            position: _mapPosition,
            infoWindow: InfoWindow(
              title: _address,
            ),
          ),
        );
      });
    }

    void _updateMapInfo() async {
      Firestore db = Firestore.instance;
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String uid = user.uid;
      await _getPosition();
      Map<String, Map> nuevo;

      nuevo = {
        'ubicacion': {
          'posicion': GeoPoint(lat, long),
          'direccion': _markers.elementAt(0).infoWindow.title,
        }
      };
      db.collection('usuarios').document(uid).updateData(nuevo);
      print('Update map info completado');
    }

    void _buscarLugar() async {
      try {
        placemark = await Geolocator()
            .placemarkFromAddress(mapTextController.text.trim());
        print(placemark);
        var lugarBuscado = LatLng(
            placemark[0].position.latitude, placemark[0].position.longitude);
        print(lugarBuscado);
        _address = placemark[0].name.toString() +
            ',' +
            placemark[0].locality.toString() +
            ',' +
            placemark[0].postalCode.toString();
        _putMarker(lugarBuscado);
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192.8334901395799,
          target: lugarBuscado,
          tilt: 10,
          zoom: 16,
        )));
      } catch (error) {
        print(error);
      }
    }

    void _isMapInfo() async {
      try {
        var doc = await Firestore.instance
            .collection('usuarios')
            .document(widget.uid)
            .get();
        if (doc.data['ubicacion'] != null) {
          mapTextController.text =
              doc.data['ubicacion']['direccion'].toString();
          _markers.clear();
          posMarker = new LatLng(doc.data['ubicacion']['posicion'].latitude,
              doc.data['ubicacion']['posicion'].longitude);
         _putMarker(posMarker);
        }
        
      } catch (error) {
        print(error);
      }
    }

    _buildPerfil() {
      return Scaffold(
        appBar: AppBar(
          title: Text('Perfil'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      height: 200,
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: imgWid(),
                      ),
                    ),
                    Container(
                      width: 150,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.only(right: 50),
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
      );
    }
    _buildUbicacion() {
       
      return Scaffold(
        appBar: AppBar(
          title: Text('Ubicaciones'),
        ),
        drawer: DrawerMenu(),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height - 183,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  _getPosition();
                  _isMapInfo();
                },
                initialCameraPosition: CameraPosition(
                  bearing: 192.8334901395799,
                  target: posMarker,
                  tilt: 10,
                  zoom: 15,
                ),
                compassEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                markers: _markers,
                onTap: (pos) {
                  _putMarker(pos);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 60, left: 8),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(width: 2, color: Colors.black26)),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: mapTextController,
                  onEditingComplete: () {
                    _buscarLugar();
                  },
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      wordSpacing: 2.0,
                      color: Colors.black),
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.business,
                      ),
                      hintText: 'str,adrs,places',
                      hintStyle:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: _updateMapInfo,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.green,
          child: const Icon(Icons.cloud_done, size: 26.0),
          tooltip: 'guardar tu posicion y busqueda',
        ),
      );
    }

    void _onItemTapped(int index) {
      setState(() {
        _index = index;
      });
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_identity,
              color: Colors.blueAccent,
            ),
            title: Text('perfil'),
          ),
          BottomNavigationBarItem(
            //icon: Icon(CupertinoIcons.location),
            icon: Icon(
              Icons.map,
              color: Colors.deepOrange,
            ),
            title: Text('ubicacion'),
          ),
        ],
        currentIndex: _index,
        onTap: _onItemTapped,
      ),
      drawer: DrawerMenu(),
      body: _index == 0 ? _buildPerfil() :  _buildUbicacion(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: getImage,
              tooltip: 'Pick Image',
              child: Icon(Icons.add_a_photo),
            )
          : null,
    );
  }
}
