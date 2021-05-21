import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:center_notify/Districts.dart';
import 'package:intl/intl.dart';
import 'States.dart';

// import 'package:flutter_background/flutter_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String stateName;
  final String districtName;
  final String districtID;

  final bool isStateSelected;
  final bool isDistrictSelected;
  final bool pressNotify;
  final bool isDurationSelected;

  final int duration;

  final List districts;

  final Future<SharedPreferences> preferencesInstance;
  final AndroidNotificationChannel channel;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  HomePage(
      {this.stateName,
      this.districtName,
      this.districtID,
      this.isStateSelected,
      this.isDistrictSelected,
      this.pressNotify,
      this.isDurationSelected,
      this.duration,
      this.districts,
      this.preferencesInstance,
      this.channel,
      this.flutterLocalNotificationsPlugin});

  @override
  HomePageState createState() => HomePageState(
      stateName: this.stateName,
      districtName: this.districtName,
      districtID: this.districtID,
      isStateSelected: this.isStateSelected,
      isDistrictSelected: this.isDistrictSelected,
      pressNotify: this.pressNotify,
      isDurationSelected: this.isDurationSelected,
      duration: this.duration,
      districts: this.districts,
      preferencesInstance: this.preferencesInstance,
      channel: this.channel,
      flutterLocalNotificationsPlugin: this.flutterLocalNotificationsPlugin);
}

class HomePageState extends State<HomePage> {
  HomePageState(
      {this.stateName,
      this.districtName,
      this.districtID,
      this.isStateSelected,
      this.isDistrictSelected,
      this.pressNotify,
      this.isDurationSelected,
      this.duration,
      this.districts,
      this.preferencesInstance,
      this.channel,
      this.flutterLocalNotificationsPlugin});

  String stateName;
  String districtName;
  String districtID;

  bool isStateSelected;
  bool isDistrictSelected;
  bool pressNotify;
  bool isDurationSelected;

  int duration;

  List durations = [3, 15, 30, 60, 120, 180, 240];
  List districts;
  List data;

  String url;
  String _chosenDateTime;

  int indexOfList;
  int numberOfCovaxin = 0;
  int numberOfCovishield = 0;
  int numberOfCovaxinPreviousValue;
  int numberOfCovishieldPreviousValue;
  int count = 0;

  bool isCompleted = true;
  bool isTimeOn = false;
  bool initialized = false;

  Timer _timer;

  Future<SharedPreferences> preferencesInstance;

  DateFormat formatter = DateFormat('dd-MM-yyyy');
  AndroidNotificationChannel channel;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    /// Initialize the saved values in SharedPreferences

    // backgroundInitialize();

    /// Initialize the AndroidNotification Settings for LocalNotifications
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  removeKey(key) async {
    // Future<SharedPreferences> _prefs = preferencesInstance;
    final SharedPreferences prefs = await preferencesInstance;
    prefs.remove("$key");
  }

  /// Adding an integer value
  dynamic putInt(key, val) async {
    // Future<SharedPreferences> _prefs = preferencesInstance;
    final SharedPreferences prefs = await preferencesInstance;
    var _res = prefs.setInt("$key", val);
    return _res;
  }

  /// Adding a string value
  putString(key, val) async {
    // Future<SharedPreferences> _prefs = preferencesInstance;
    final SharedPreferences prefs = await preferencesInstance;
    var _res = prefs.setString("$key", val);
    return _res;
  }

  /// Adding List of Strings
  putJSON(key, val) async {
    // Future<SharedPreferences> _prefs = preferencesInstance;
    final SharedPreferences prefs = await preferencesInstance;
    var valString = jsonEncode(val);
    var _res = prefs.setString("$key", valString);
    return _res;
  }

  Future<String> getJsonData(String url, String district) async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var convertDataToJson = json.decode(response.body);
    data = convertDataToJson['sessions'];
    numberOfCovaxinPreviousValue = numberOfCovaxin;
    numberOfCovishieldPreviousValue = numberOfCovishield;
    numberOfCovaxin = 0;
    numberOfCovishield = 0;
    if (data != null && data.length != 0) {
      data.forEach((element) {
        if (element['vaccine'] == "COVAXIN")
          numberOfCovaxin += element['available_capacity'].round();
        else if (element['vaccine'] == "COVISHIELD") {
          numberOfCovishield += element['available_capacity'].round();
        }
      });
    }

    setState(() {
      isCompleted = true;
    });
    if (numberOfCovaxinPreviousValue != numberOfCovaxin ||
        numberOfCovishieldPreviousValue !=
            numberOfCovishield) if (numberOfCovaxin > 0 ||
        numberOfCovishield > 0) {
      showNotification(numberOfCovaxin, numberOfCovishield, district);
    }
    return "Success";
  }

  void timerCall(String url, String district, int duration) {
    count = 0;
    if (isTimeOn == true)
      _timer = Timer.periodic(Duration(seconds: duration), (timer) {
        print("${count++}");
        print(_chosenDateTime);
        isCompleted = false;
        setState(() {
          getJsonData(url, district);
        });
      });
  }

  void showNotification(int covaxin, int covishield, String district) {
    flutterLocalNotificationsPlugin.show(
        0,
        "$district",
        "Covishield: $covishield\nCovaxin: $covaxin",
        NotificationDetails(
            android: AndroidNotificationDetails(
                channel.id, channel.name, channel.description,
                importance: Importance.high, icon: '@mipmap/ic_launcher')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Container(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 38, 40, 47),
                        ),
                        padding: EdgeInsets.all(20),
                        child: DropdownButton(
                            isExpanded: true,
                            iconDisabledColor:
                                Theme.of(context).accentColor.withOpacity(0.2),
                            iconEnabledColor: Theme.of(context).accentColor,
                            dropdownColor: Color.fromARGB(255, 38, 40, 47),
                            hint: isStateSelected == false
                                ? Text(
                                    stateName,
                                    style: TextStyle(color: Colors.white54),
                                  )
                                : Text(
                                    stateName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                            items: List.generate(
                              states.length,
                              (index) {
                                return DropdownMenuItem(
                                  child: Text(
                                    states[index]['state_name'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  value: states[index]['state_id'],
                                  onTap: () {
                                    stateName = states[index]['state_name'];
                                    putString("stateName",
                                        states[index]['state_name']);
                                    putJSON(
                                        "districts",
                                        allDistricts[
                                            states[index]['state_id'] - 1]);
                                  },
                                );
                              },
                            ),
                            onChanged: (value) {
                              if (_timer != null) {
                                _timer.cancel();
                                _timer = null;
                              }
                              isStateSelected = true;
                              isDistrictSelected = false;
                              pressNotify = false;
                              districtName = "Select District";
                              removeKey("districtName");
                              setState(() {
                                districts = allDistricts[value - 1];
                              });
                            }),
                      ),
                      Container(
                        color: Color.fromARGB(255, 38, 40, 47),
                        padding: EdgeInsets.all(20),
                        child: DropdownButton(
                            isExpanded: true,
                            iconDisabledColor:
                                Theme.of(context).accentColor.withOpacity(0.2),
                            iconEnabledColor: Theme.of(context).accentColor,
                            dropdownColor: Color.fromARGB(255, 38, 40, 47),
                            // autofocus: true,
                            hint: isDistrictSelected == false
                                ? Text(
                                    districtName,
                                    style: TextStyle(color: Colors.white54),
                                  )
                                : Text(
                                    districtName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                            items: List.generate(
                              districts.length,
                              (index) {
                                return DropdownMenuItem(
                                  child: Text(
                                    districts[index]['district_name'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  value: districts[index]['district_id'],
                                  onTap: () {
                                    districtName =
                                        districts[index]['district_name'];
                                    putString("districtName",
                                        districts[index]['district_name']);
                                    putString(
                                        "districtID",
                                        districts[index]['district_id']
                                            .toString());
                                  },
                                );
                              },
                            ),
                            onChanged: (value) {
                              if (_timer != null) {
                                _timer.cancel();
                                _timer = null;
                              }
                              pressNotify = false;
                              setState(() {
                                // isCompleted = false;
                                districtID = value.toString();
                                isDistrictSelected = true;
                                isStateSelected = true;
                              });
                            }),
                      ),
                      Container(
                        color: Color.fromARGB(255, 38, 40, 47),
                        padding: EdgeInsets.all(20),
                        child: DropdownButton(
                            isExpanded: true,
                            iconDisabledColor:
                                Theme.of(context).accentColor.withOpacity(0.2),
                            iconEnabledColor: Theme.of(context).accentColor,
                            dropdownColor: Color.fromARGB(255, 38, 40, 47),
                            hint: isDurationSelected == false
                                ? Text(
                                    'Duration of Notification',
                                    style: TextStyle(color: Colors.white54),
                                  )
                                : Text(
                                    '${duration}s',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            items: isStateSelected == false ||
                                    isDistrictSelected == false
                                ? null
                                : List.generate(
                                    durations.length,
                                    (index) {
                                      return DropdownMenuItem(
                                        child: Text(
                                          '${durations[index]}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value: durations[index],
                                        onTap: () {
                                          duration = durations[index];
                                          putInt("duration", durations[index]);
                                        },
                                      );
                                    },
                                  ),
                            onChanged: (value) {
                              if (_timer != null) {
                                _timer.cancel();
                                _timer = null;
                              }
                              pressNotify = false;
                              setState(() {
                                duration = value;
                                isDurationSelected = true;
                              });
                            }),
                      ),
                      Container(
                        height: 90,
                        width: 400,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(brightness: Brightness.dark),
                          child: CupertinoDatePicker(
                              backgroundColor: Color.fromARGB(255, 38, 40, 47),
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime:
                                  DateTime.now().add(Duration(hours: 8)),
                              onDateTimeChanged: (val) {
                                setState(() {
                                  pressNotify = false;
                                  if (_timer != null) {
                                    _timer.cancel();
                                    _timer = null;
                                  }
                                  _chosenDateTime = formatter.format(val);
                                });
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            isStateSelected == false ||
                                    isDistrictSelected == false ||
                                    isDurationSelected == false ||
                                    pressNotify == false
                                ? "Notify"
                                : "Stop",
                            style: isStateSelected == false ||
                                    isDistrictSelected == false ||
                                    isDurationSelected == false
                                ? TextStyle(color: Colors.white24)
                                : TextStyle(color: Colors.black),
                          ),
                          onPressed: isStateSelected == false ||
                                  isDistrictSelected == false ||
                                  isDurationSelected == false
                              ? null
                              : () {
                                  print(_chosenDateTime);
                                  setState(() {
                                    if (_chosenDateTime == null) {
                                      _chosenDateTime = formatter
                                          .format(DateTime.now().add(Duration(
                                        hours: 8,
                                      )));
                                    }
                                    if (_timer != null) {
                                      _timer.cancel();
                                      _timer = null;
                                      pressNotify = false;
                                    } else {
                                      isCompleted = false;
                                      isTimeOn = true;
                                      pressNotify = true;
                                      url =
                                          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$districtID&date=$_chosenDateTime";
                                      getJsonData(url, districtName);
                                      timerCall(url, districtName, duration);
                                    }
                                  });
                                },
                        ),
                      ),
                      Container(
                        // color: Theme.of(context).primaryColor,
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: TotalVaccines(
                            numberOfCovaxin: numberOfCovaxin,
                            numberOfCovishield: numberOfCovishield,
                            isStateSelected: isStateSelected,
                            isDistrictSelected: isDistrictSelected,
                            isCompleted: isCompleted,
                            isDurationSelected: isDurationSelected,
                            pressNotify: pressNotify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}

class TotalVaccines extends StatelessWidget {
  int numberOfCovaxin;
  int numberOfCovishield;
  bool isStateSelected;
  bool isDistrictSelected;
  bool isCompleted;
  bool isDurationSelected;
  bool pressNotify;

  TotalVaccines(
      {this.numberOfCovaxin,
      this.numberOfCovishield,
      this.isStateSelected,
      this.isDistrictSelected,
      this.isCompleted,
      this.isDurationSelected,
      this.pressNotify});

  @override
  Widget build(BuildContext context) {
    if (isCompleted == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.shrink(),
          LinearProgressIndicator(
            minHeight: 2,
            color: Theme.of(context).accentColor,
            backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: isStateSelected == false
          ? Text(
              "Please select state",
              style: TextStyle(color: Colors.white),
            )
          : isDistrictSelected == false
              ? Text(
                  "Please select district",
                  style: TextStyle(color: Colors.white),
                )
              : isDurationSelected == false
                  ? Text(
                      "Please select duration",
                      style: TextStyle(color: Colors.white),
                    )
                  : pressNotify == false
                      ? Text(
                          "Please press Notify button",
                          style: TextStyle(color: Colors.white),
                        )
                      : Container(
                          child: Text(
                            'Covishield: $numberOfCovishield\n Covaxin: $numberOfCovaxin',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
    );
  }
}
