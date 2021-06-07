import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CenterNotifyApp());
}

class CenterNotifyApp extends StatelessWidget {
  const CenterNotifyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 51, 51, 61),
          accentColor: Color.fromARGB(255, 9, 175, 121),
          accentColorBrightness: Brightness.light),
      // theme: ThemeData.dark(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.dark,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String stateName;
  String districtName;
  String districtID = " ";

  bool isStateSelected = false;
  bool isDistrictSelected = false;
  bool pressNotify = false;
  bool isDurationSelected = false;

  int duration;

  List districts = [];

   Future<SharedPreferences> preferencesInstance = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    initializePreference();


    Timer(Duration(seconds: 5),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) => HomePage(stateName: this.stateName,
                    districtName: this.districtName,
                    districtID: this.districtID,
                    isStateSelected: this.isStateSelected,
                    isDistrictSelected: this.isDistrictSelected,
                    pressNotify: this.pressNotify,
                    isDurationSelected: this.isDurationSelected,
                    duration: this.duration, preferencesInstance: this.preferencesInstance, districts: districts,)
            )
        )
    );

  }

  Future<String> initializePreference() async {
    var preferences = await SharedPreferences.getInstance();
    stateName = preferences.getString("stateName") ?? "Select State";
    districtName = preferences.getString("districtName") ?? "Select District";
    duration = preferences.getInt("duration") ?? null;
    districtID = preferences.getString("districtID") ?? null;

    if (preferences.getString("stateName") != null) {
      isStateSelected = true;
      isDistrictSelected = false;
      pressNotify = false;
      var jsonString = preferences.getString("districts") ?? null;
      if (jsonString != null) districts = jsonDecode(jsonString);
      if (preferences.getString("districtName") != null) {
        pressNotify = false;
        isDistrictSelected = true;
        isStateSelected = true;
      }
    }

    if (preferences.getInt("duration") != null) {
      isDurationSelected = true;
      pressNotify = false;
    }

    return "Initialized";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
            child: Container(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 100,
                width: 100,
                child: Image(
                  image: AssetImage("assets/images/injection.png"),
                ),
              ),
              Container(
                width: 300,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: Theme.of(context).accentColor,
                  backgroundColor:
                      Theme.of(context).accentColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        )));
  }
}



