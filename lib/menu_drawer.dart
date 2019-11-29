import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 50, left: 10),
            width: double.infinity,
            height: 100,
            child: Text(
              'Menu Drawer',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5, right: 80),
            width: 220,
            height: 0.5,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Colors.green,
              ),
              title: Text(
                'Mi perfil',
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.cancel,
                color: Colors.redAccent,
              ),
              title: Text('Salir'),
              onTap: () {
                setState(() {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamed('/');
                  print('desconectado');
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
