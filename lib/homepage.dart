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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

/// Port Isolate
/*
import 'dart:isolate';
const String isolateName = 'isolate';
final ReceivePort port = ReceivePort();
final DateTime now = DateTime.now();
final int isolateId = Isolate.current.hashCode;
uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
uiSendPort?.send(null);
print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
IsolateNameServer.registerPortWithName(
  port.sendPort,
  isolateName,
);
port.listen((_) async => await _incrementCounter());
static SendPort uiSendPort;
*/

/// create channel for notification
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Creating instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Callback function for AlarmFire
void scheduleNotification() async {
  print("printHello()");
  List data;
  int numberOfCovaxin = 0;
  int numberOfCovishield = 0;

  /// get shared values
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var districtID = prefs.getString("districtID");
  var chosenDateTime = prefs.getString("chosenDateTime");
  var districtName = prefs.getString("districtName");
  int numberOfCovaxinPreviousValue = prefs.getInt("numberOfCovaxin");
  int numberOfCovishieldPreviousValue = prefs.getInt("numberOfCovishield");

  /// URL for API
  String url =
      "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$districtID&date=$chosenDateTime";

  /// get data form API
  var response = await http
      .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
  var convertDataToJson = json.decode(response.body);
  data = convertDataToJson['sessions'];
  List<String> lines = [];
  // ["1","2","3","4","5","6","7","7","8","8","9",];
  /// find number of vaccines and them to the list
  if (data != null && data.length != 0) {
    data.forEach((element) {
      if (element['vaccine'] == "COVAXIN") {
        if (element['available_capacity'].round() > 0) {
          List centerName = element['name'].toString().split(' ');
          lines.add(
              "COVAXIN: <b>${element['available_capacity'].round()}</b>  (<b>${element['pincode']}</b>: <i>${centerName[0]} ${centerName[1]}</i>)");
        }
        numberOfCovaxin += element['available_capacity'].round();
      } else if (element['vaccine'] == "COVISHIELD") {
        if (element['available_capacity'].round() > 0) {
          List centerName = element['name'].toString().split(' ');
          lines.add(
              "COVISHIELD: <b>${element['available_capacity'].round()}</b>  (<b>${element['pincode']}</b>: <i>${centerName[0]} ${centerName[1]}</i>)");
        }
        numberOfCovishield += element['available_capacity'].round();
      }
    });
  }

  final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      htmlFormatLines: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: false);
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(channel.id, channel.name, channel.description,
          styleInformation: inboxStyleInformation,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high);
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  /// show Notification
  // if (numberOfCovaxinPreviousValue != numberOfCovaxin ||
  //     numberOfCovishieldPreviousValue !=
  //         numberOfCovishield) if (numberOfCovaxin > 0 ||
  //     numberOfCovishield > 0) {
  putInt("numberOfCovaxin", numberOfCovaxin);
  putInt("numberOfCovishield", numberOfCovishield);
  flutterLocalNotificationsPlugin.show(
      0,
      "$districtName",
      "Covishield: $numberOfCovishield\nCovaxin: $numberOfCovaxin",
      platformChannelSpecifics);
  // }
}

/// Remove shared value
removeKey(key) async {
  Future<SharedPreferences> preferencesInstance =
      SharedPreferences.getInstance();
  final SharedPreferences prefs = await preferencesInstance;
  prefs.remove("$key");
}

/// Adding an integer value
dynamic putInt(key, val) async {
  Future<SharedPreferences> preferencesInstance =
      SharedPreferences.getInstance();
  final SharedPreferences prefs = await preferencesInstance;
  var _res = prefs.setInt("$key", val);
  return _res;
}

/// Adding a string value
putString(key, val) async {
  Future<SharedPreferences> preferencesInstance =
      SharedPreferences.getInstance();
  final SharedPreferences prefs = await preferencesInstance;
  var _res = prefs.setString("$key", val);
  return _res;
}

/// Adding List of Strings
putJSON(key, val) async {
  Future<SharedPreferences> preferencesInstance =
      SharedPreferences.getInstance();
  final SharedPreferences prefs = await preferencesInstance;
  var valString = jsonEncode(val);
  var _res = prefs.setString("$key", valString);
  return _res;
}

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

  HomePage({
    this.stateName,
    this.districtName,
    this.districtID,
    this.isStateSelected,
    this.isDistrictSelected,
    this.pressNotify,
    this.isDurationSelected,
    this.duration,
    this.districts,
    this.preferencesInstance,
  });

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
      );
}

class HomePageState extends State<HomePage> {
  HomePageState({
    this.stateName,
    this.districtName,
    this.districtID,
    this.isStateSelected,
    this.isDistrictSelected,
    this.pressNotify,
    this.isDurationSelected,
    this.duration,
    this.districts,
    this.preferencesInstance,
  });

  String stateName;
  String districtName;
  String districtID;

  bool isStateSelected;
  bool isDistrictSelected;
  bool pressNotify;
  bool isDurationSelected;
  bool isCompleted = true;
  bool isTimeOn = false;
  bool initialized = false;
  bool isBackgroundNotificationON = false;
  static bool isPincodeSelected = false;

  List durations = [3, 15, 30, 60, 120, 180, 240];
  List districts;
  List data;
  List pincodes = [];

  String url;
  String _chosenDateTime;

  int indexOfList;
  int numberOfCovaxin = 0;
  int numberOfCovishield = 0;
  int numberOfCovaxinPreviousValue;
  int numberOfCovishieldPreviousValue;
  int count = 0;
  int duration;

  Timer _timer;

  static List<bool> isCheckedList = [];
  List selectedPincodes = [];

  // bool _isSelected = false;

  Future<SharedPreferences> preferencesInstance;

  DateFormat formatter = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();
    registerChannel();
  }

  registerChannel() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Initialize the AndroidNotification Settings for LocalNotifications
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void setAlarmFire() async {
    print("Set Alarm Fire");
    final int helloAlarmID = 0;
    await AndroidAlarmManager.periodic(
      const Duration(seconds: 1), helloAlarmID, scheduleNotification,
      // exact: true
    );
  }

  void addPincodes(String districtID, String chosenDateTime) async {
    pincodes?.clear();
    var response = await http.get(
        Uri.encodeFull(
            "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$districtID&date=$chosenDateTime"),
        headers: {"Accept": "application/json"});
    var convertDataToJson = json.decode(response.body);
    data = convertDataToJson['sessions'];
    Set pincodeSet = new Set();
    if (data != null && data.length != 0) {
      data.forEach((element) {
        pincodeSet.add(element['pincode']);
      });
    }
    pincodeSet.forEach((element) {
      pincodes.add(element);
    });
    setState(() {
      pincodes?.sort();
      isCheckedList.clear();
      // if(isCheckedList == null)
      //   isCheckedList = List(pincodes.length);
      for (int i = 0; i < pincodes.length; i++) isCheckedList.add(false);
      print(pincodes);
    });
    // return "Success";
  }

  Future<String> slotNotifyWithoutNotification(
      String url, String district) async {
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
          slotNotifyWithoutNotification(url, district);
        });
      });
  }

  void changeState(bool value) {
    setState(() {
      print(value.toString());
      isPincodeSelected = value;
    });
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
                  padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
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
                              putString(
                                  "stateName", states[index]['state_name']);
                              putJSON("districts",
                                  allDistricts[states[index]['state_id'] - 1]);
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
                  padding: EdgeInsets.fromLTRB(14, 8, 14, 6),
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
                              districtName = districts[index]['district_name'];
                              putString("districtName",
                                  districts[index]['district_name']);
                              putString("districtID",
                                  districts[index]['district_id'].toString());
                              addPincodes(
                                  districts[index]['district_id'].toString(),
                                  formatter.format(DateTime.now().add(Duration(
                                    hours: 8,
                                  ))));
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
                  padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Pincodes",
                            style: TextStyle(
                                color: pincodes.length > 0
                                    ? Colors.white
                                    : Colors.white54),
                          ),
                          IconButton(
                            alignment: Alignment.centerRight,
                            onPressed: pincodes.length == 0
                                ? () {}
                                : () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            // scrollable: true,
                                            backgroundColor:
                                                Color.fromARGB(255, 38, 40, 47),
                                            title: Text("Select Pincodes",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            content: StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setState) {
                                              return ListView.builder(
                                                  itemCount: pincodes.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return CheckboxListTile(
                                                      dense: true,
                                                      activeColor:
                                                          Theme.of(context)
                                                              .accentColor,
                                                      checkColor: Colors.white,
                                                      title: Text(
                                                          "${pincodes[index]}",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      // subtitle: Text('sub demo mode'),
                                                      value:
                                                          isCheckedList[index],
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          print(
                                                              value.toString());
                                                          isCheckedList[index] =
                                                              value;
                                                        });
                                                      },
                                                    );
                                                  });
                                            }),
                                            actions: <Widget>[
                                              FlatButton(
                                                  onPressed: () {
                                                    selectedPincodes.clear();
                                                    for (int i = 0;
                                                        i < pincodes.length;
                                                        i++) {
                                                      if (isCheckedList[i] ==
                                                          true)
                                                        selectedPincodes
                                                            .add(pincodes[i]);
                                                    }

                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .accentColor),
                                                  )),
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel",
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .accentColor))),
                                            ],
                                          );
                                        });
                                  },
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: pincodes.length > 0 ? Theme.of(context).accentColor : Theme.of(context).accentColor.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.white,
                        thickness: 0.2,
                      )
                    ],
                  ),
                  width: 300,
                ),
                // Container(
                //   color: Color.fromARGB(255, 38, 40, 47),
                //   padding: EdgeInsets.all(20),
                //   child: DropdownButton(
                //       isExpanded: true,
                //       iconDisabledColor:
                //           Theme.of(context).accentColor.withOpacity(0.2),
                //       iconEnabledColor: Theme.of(context).accentColor,
                //       dropdownColor: Color.fromARGB(255, 38, 40, 47),
                //       hint: isDurationSelected == false
                //           ? Text(
                //               'Duration of Notification',
                //               style: TextStyle(color: Colors.white54),
                //             )
                //           : Text(
                //               '${duration}s',
                //               style: TextStyle(color: Colors.white),
                //             ),
                //       items: isStateSelected == false ||
                //               isDistrictSelected == false
                //           ? null
                //           : List.generate(
                //               durations.length,
                //               (index) {
                //                 return DropdownMenuItem(
                //                   child: Text(
                //                     '${durations[index]}',
                //                     style: TextStyle(color: Colors.white),
                //                   ),
                //                   value: durations[index],
                //                   onTap: () {
                //                     duration = durations[index];
                //                     putInt("duration", durations[index]);
                //                   },
                //                 );
                //               },
                //             ),
                //       onChanged: (value) {
                //         if (_timer != null) {
                //           _timer.cancel();
                //           _timer = null;
                //         }
                //         pressNotify = false;
                //         setState(() {
                //           duration = value;
                //           isDurationSelected = true;
                //         });
                //       }),
                // ),
                Container(
                  height: 90,
                  width: 400,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(brightness: Brightness.dark),
                    child: CupertinoDatePicker(
                        backgroundColor: Color.fromARGB(255, 38, 40, 47),
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: DateTime.now().add(Duration(hours: 8)),
                        onDateTimeChanged: (val) {
                          setState(() {
                            pressNotify = false;
                            if (_timer != null) {
                              _timer.cancel();
                              _timer = null;
                            }
                            _chosenDateTime = formatter.format(val);
                            putString("chosenDateTime", _chosenDateTime);
                          });
                        }),
                  ),
                ),
                Container(
                    color: Color.fromARGB(255, 38, 40, 47),
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Notification",
                            style: isBackgroundNotificationON
                                ? TextStyle(color: Colors.white, fontSize: 17)
                                : TextStyle(
                                    color: Colors.white54, fontSize: 17)),
                        Switch(
                          onChanged: (bool value) {
                            setState(() {
                              if (!value) {
                                print("Cancel!!");
                                AndroidAlarmManager.cancel(0);
                              }
                              isBackgroundNotificationON = value;
                            });
                          },
                          value: isBackgroundNotificationON,
                          activeColor: Theme.of(context).accentColor,
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Theme.of(context).primaryColor,
                        )
                      ],
                    )),
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
                            // print(_chosenDateTime);
                            setState(() {
                              if (_chosenDateTime == null) {
                                _chosenDateTime = formatter
                                    .format(DateTime.now().add(Duration(
                                  hours: 8,
                                )));
                                putString("chosenDateTime", _chosenDateTime);
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
                                putString("url", url);
                                // slotNotifyWithoutNotification(
                                //     url, districtName);
                                // timerCall(url, districtName, duration);
                                // if (isBackgroundNotificationON)
                                setAlarmFire();
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
  final int numberOfCovaxin;
  final numberOfCovishield;
  final bool isStateSelected;
  final bool isDistrictSelected;
  final bool isCompleted;
  final bool isDurationSelected;
  final bool pressNotify;

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
