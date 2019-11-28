import 'dart:convert';

import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
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
            margin: EdgeInsets.only(top: 5,bottom: 5,right: 80),
            width: 220,
            height: 0.5,
            decoration: BoxDecoration(
              border: Border.all(width: 1,color: Colors.grey),
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
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.cancel,
                color: Colors.redAccent,
              ),
              title: Text('Salir'),
              onTap: () {},
            ),
          )
        ],
      ),
    );
  }
}
