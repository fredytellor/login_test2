import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 50,left: 10),
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
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(
              'Mi perfil',           
            ),
            onTap: (){},
          ),
        ],
      ),
    );
  }
}
