import 'dart:async';
import 'package:credestest/Loader/lineLoader.dart';
import 'package:credestest/screens/homeScreen.dart';
import 'package:flutter/material.dart';

class PageLoader extends StatefulWidget {
  const PageLoader({Key? key}) : super(key: key);

  @override
  State<PageLoader> createState() => _PageLoaderState();
}

class _PageLoaderState extends State<PageLoader> {
  @override
  void initState() {
    super.initState();
    Timer( Duration(seconds: 1), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Adding...'),
            SizedBox(height: 20,),
           GlowingLoader(
          glowColor: Colors.white, 
          width: 200,
          height: 10,
          duration:  Duration(milliseconds: 1000)
        ),
          ],
        ),
      ),
    );
  }
}
