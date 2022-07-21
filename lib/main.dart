import 'package:flutter/material.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/home/home_page.dart';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "صن لايت للكهربائيات",
        theme: ThemeData(
            fontFamily: 'ElMessiri',
            primaryColor: kSecondaryColorBG,
            accentColor: kSecondaryColorBG,
            visualDensity: VisualDensity.adaptivePlatformDensity,),
        home: HomePage(),
  ),
  );
}