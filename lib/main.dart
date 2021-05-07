import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:center_notify/Districts.dart';
import 'States.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 51, 51, 61),
          accentColor: Color.fromARGB(255, 9, 175, 121),
          accentColorBrightness: Brightness.light),
      // theme: ThemeData.dark(),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.dark,
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static String _value = " ";
  static String districtName = "Select District";
  List districts = [];
  List data;
  String url;
  int indexOfList;
  List durations = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // int totalVaccines = 0;
  String stateName = "Select State";
  bool isCompleted = true;
  bool isStateSelected = false;
  bool isDistrictSelected = false;
  bool isTimeOn = false;
  Timer _timer;
  int numberOfCovaxin = 0;
  int numberOfCovishield = 0;
  int count = 0;
  bool isDurationSelected = false;
  int duration;
  bool pressNotify = false;

  @override
  void initState() {
    super.initState();
    // print(states.length);
    // this.getJsonData();
  }

  Future<String> getJsonData() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    // print(response.body);

    setState(() {
      var convertDataToJson = json.decode(response.body);
      data = convertDataToJson['sessions'];
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
      isCompleted = true;
    });
    return "Success";
  }

  void call_API_with_time(int duration) {
    count = 0;
    if (isTimeOn == true)
      _timer = Timer.periodic(Duration(seconds: duration), (timer) {
        print("${count++}");
        isCompleted = false;
        setState(() {
          getJsonData();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 51, 51, 61),
        body: Center(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    // borderRadius: Radius,
                    color: Color.fromARGB(255, 38, 40, 47),
                  ),
                  // color: Color.fromARGB(255, 38, 40, 47),
                  padding: EdgeInsets.all(20),
                  child: DropdownButton(
                      isExpanded: true,
                      iconDisabledColor:
                          Theme.of(context).accentColor.withOpacity(0.2),
                      iconEnabledColor: Theme.of(context).accentColor,
                      dropdownColor: Color.fromARGB(255, 38, 40, 47),
                      // autofocus: true,
                      hint: isStateSelected == false
                          ? Text(
                              "Select State",
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
                            },
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (_timer != null) _timer.cancel();
                        isStateSelected = true;
                        isDistrictSelected = false;
                        pressNotify = false;
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
                      dropdownColor: Color.fromARGB(255, 38,40,47),
                      // autofocus: true,
                      hint: isDistrictSelected == false
                          ? Text(
                              'Select District',
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
                            },
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (_timer != null) _timer.cancel();
                        pressNotify = false;
                        setState(() {
                          _value = value.toString();
                          // isCompleted = false;
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
                      dropdownColor: Color.fromARGB(255, 38,40,47),
                      // value: _value,
                      // autofocus: true,
                      hint: isDurationSelected == false
                          ? Text(
                              'Duration of Notification',
                              style: TextStyle(color: Colors.white54),
                            )
                          : Text(
                              '$duration',
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
                                  },
                                );
                              },
                            ),
                      onChanged: (value) {
                        if (_timer != null) _timer.cancel();
                        pressNotify = false;
                        setState(() {
                          duration = value;
                          isDurationSelected = true;
                        });
                      }),
                ),
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    "Notify",
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
                          if (_timer != null) _timer.cancel();
                          setState(() {
                            isCompleted = false;
                            isTimeOn = true;
                            pressNotify = true;
                            url =
                                "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$_value&date=08-05-2021";
                            getJsonData();
                            call_API_with_time(duration);
                          });
                        },
                ),
                TotalVaccines(
                  numberOfCovaxin: numberOfCovaxin,
                  numberOfCovishield: numberOfCovishield,
                  isStateSelected: isStateSelected,
                  isDistrictSelected: isDistrictSelected,
                  isCompleted: isCompleted,
                  isDurationSelected: isDurationSelected,
                  pressNotify: pressNotify,
                )
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
      return CircularProgressIndicator(
        backgroundColor: Color.fromARGB(255, 9, 175, 121),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
