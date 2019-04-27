import 'package:flutter/material.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "FB Audience Network Example",
          ),
        ),
        body: Center(
          child: FutureBuilder(
            future: FacebookAudienceNetwork.getBatteryLevel(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  "Battery Level: ${snapshot.data}",
                );
              }
              if (snapshot.hasError) {
                return Text(
                  "Battery Level Error: ${snapshot.error}",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                );
              }

              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
