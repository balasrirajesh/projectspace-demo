import 'package:alumini_screen/src/pages/features/login_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main(){
  if(kIsWeb){runApp(DevicePreview(builder: (context) => MyApp()));}
  else{
    runApp(MyApp());
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}