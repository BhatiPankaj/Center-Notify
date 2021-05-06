import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:center_notify/Districts.dart';
import 'States.dart';

void main() => runApp(MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
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
        appBar: new AppBar(
          title: new Text("Retrieve JSON"),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: DropdownButton(
                      // value: _value,
                      hint: isStateSelected == false
                          ? Text("Select State")
                          : Text(stateName),
                      items: List.generate(
                        states.length,
                        (index) {
                          return DropdownMenuItem(
                            child: Text(states[index]['state_name']),
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
                  padding: EdgeInsets.all(20),
                  child: DropdownButton(
                      // value: _value,
                      hint: isDistrictSelected == false
                          ? Text('Select District')
                          : Text(districtName),
                      items: List.generate(
                        districts.length,
                        (index) {
                          return DropdownMenuItem(
                            child: Text(districts[index]['district_name']),
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
                  padding: EdgeInsets.all(20),
                  child: DropdownButton(
                      // value: _value,
                      hint: isDurationSelected == false
                          ? Text('Duration of Notification')
                          : Text('$duration'),
                      items: List.generate(
                        durations.length,
                        (index) {
                          return DropdownMenuItem(
                            child: Text('${durations[index]}'),
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
                  child: Text("Notify"),
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
                                "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$_value&date=07-05-2021";
                            getJsonData();
                            call_API_with_time(duration);
                          });
                        },
                )
              ],
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
      return CircularProgressIndicator();
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: isStateSelected == false
          ? Text("Please select state")
          : isDistrictSelected == false
              ? Text("Please select district")
              : isDurationSelected == false
                  ? Text("Please select duration")
                  : pressNotify == false
                      ? Text("Please press Notify button")
                      : Container(
                          child: Text(
                              'Covishield: $numberOfCovishield\n Covaxin: $numberOfCovaxin'),
                        ),
    );
  }
}
