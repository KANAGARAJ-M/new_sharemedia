import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

AppBar header(context) {
  return AppBar(
    title: Text('Wavora', style: TextStyle(fontFamily: 'Ubuntu-Regular', fontSize: 24.0, fontWeight: FontWeight.w900)),
    centerTitle: true,
    actions: [Padding(
      padding: const EdgeInsets.only(right:20.0),
      child: Icon(Ionicons.notifications_outline),
    )],
  );
}
