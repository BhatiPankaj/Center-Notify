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

// List states = [];

// var districts = [Districts("South Delhi", 149), Districts("East Delhi", 145)];

class HomePageState extends State<HomePage> {
  static String _value = " ";
  static String districtName = "Select District";
  List districts = [];
  List data;
  String url;
  int indexOfList;
  int totalVaccines = 0;
  String stateName = "Select State";
  bool isCompleted = true;
  bool isStateSelected = false;
  bool isDistrictSelected = false;

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
      if (data != null && data.length != 0) {
        data.forEach((element) {
          totalVaccines += element['available_capacity'].round();
        });
      }
      isCompleted = true;
    });
    return "Success";
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
                        isStateSelected = true;
                        isDistrictSelected = false;
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
                        setState(() {
                          _value = value.toString();
                          isCompleted = false;
                          isDistrictSelected = true;
                          isStateSelected = true;
                          totalVaccines = 0;
                          url =
                              "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$_value&date=06-05-2021";
                          getJsonData();
                        });
                      }),
                ),
              ],
            ),
            TotalVaccines(
              totalVaccines: totalVaccines,
              isStateSelected: isStateSelected,
              isDistrictSelected: isDistrictSelected,
              isCompleted: isCompleted,
            )
          ],
        ));
  }
}

class TotalVaccines extends StatelessWidget {
  int totalVaccines;
  bool isStateSelected;
  bool isDistrictSelected;
  bool isCompleted;

  TotalVaccines(
      {this.totalVaccines,
      this.isStateSelected,
      this.isDistrictSelected,
      this.isCompleted});

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
              : Container(
                  child: Text('$totalVaccines'),
                ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'Product.dart';
//
// void main() => runApp(MyApp(products: fetchProducts()));
//
// List<Product> parseProducts(String responseBody) {
//   final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
//   return parsed.map<Product>((json) => Product.fromMap(json)).toList();
// }
// Future<List<Product>> fetchProducts() async {
//   final response = await http.get('api.openweathermap.org/data/2.5/box/city?bbox=12,32,15,37,10&appid=5e113a17c9fe40286c134139fd1eb996');
//   if (response.statusCode == 200) {
//     print(response.body);
//     return parseProducts(response.body);
//   } else {
//     throw Exception('Unable to fetch products from the REST API');
//   }
// }
// class MyApp extends StatelessWidget {
//   final Future<List<Product>> products;
//   MyApp({Key key, this.products}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Product Navigation demo home page', products: products),
//     );
//   }
// }
// class MyHomePage extends StatelessWidget {
//   final String title;
//   final Future<List<Product>> products;
//   MyHomePage({Key key, this.title, this.products}) : super(key: key);
//
//   // final items = Product.getProducts();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text("Product Navigation")),
//         body: Center(
//           child: FutureBuilder<List<Product>>(
//             future: products, builder: (context, snapshot) {
//             if (snapshot.hasError) print(snapshot.error);
//             return snapshot.hasData ? ProductBoxList(items: snapshot.data) :
//
//             // return the ListView widget :
//             Center(child: CircularProgressIndicator());
//           },
//           ),
//         )
//     );
//   }
// }
// class ProductBoxList extends StatelessWidget {
//   final List<Product> items;
//   ProductBoxList({Key key, this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text('Sun'),
//         );
//       },
//     );
//   }
// }
// // class ProductPage extends StatelessWidget {
// //   ProductPage({Key key, this.item}) : super(key: key);
// //   final Product item;
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(this.item.name),),
// //       body: Center(
// //         child: Container(
// //           padding: EdgeInsets.all(0),
// //           child: Column(
// //               mainAxisAlignment: MainAxisAlignment.start,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: <Widget>[
// //                 Image.asset("assets/appimages/" + this.item.image),
// //                 Expanded(
// //                     child: Container(
// //                         padding: EdgeInsets.all(5),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                           children: <Widget>[
// //                             Text(this.item.name, style:
// //                             TextStyle(fontWeight: FontWeight.bold)),
// //                             Text(this.item.description),
// //                             Text("Price: " + this.item.price.toString()),
// //                             RatingBox(),
// //                           ],
// //                         )
// //                     )
// //                 )
// //               ]
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // class RatingBox extends StatefulWidget {
// //   @override
// //   _RatingBoxState createState() =>_RatingBoxState();
// // }
// // class _RatingBoxState extends State<RatingBox> {
// //   int _rating = 0;
// //   void _setRatingAsOne() {
// //     setState(() {
// //       _rating = 1;
// //     });
// //   }
// //   void _setRatingAsTwo() {
// //     setState(() {
// //       _rating = 2;
// //     });
// //   }
// //   void _setRatingAsThree() {
// //     setState(() {
// //       _rating = 3;
// //     });
// //   }
// //   Widget build(BuildContext context) {
// //     double _size = 20;
// //     print(_rating);
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.end,
// //       crossAxisAlignment: CrossAxisAlignment.end,
// //       mainAxisSize: MainAxisSize.max,
// //
// //       children: <Widget>[
// //         Container(
// //           padding: EdgeInsets.all(0),
// //           child: IconButton(
// //             icon: (
// //                 _rating >= 1
// //                     ? Icon(Icons.star, size: _size,)
// //                     : Icon(Icons.star_border, size: _size,)
// //             ),
// //             color: Colors.red[500], onPressed: _setRatingAsOne, iconSize: _size,
// //           ),
// //         ),
// //         Container(
// //           padding: EdgeInsets.all(0),
// //           child: IconButton(
// //             icon: (
// //                 _rating >= 2
// //                     ? Icon(Icons.star, size: _size,)
// //                     : Icon(Icons.star_border, size: _size, )
// //             ),
// //             color: Colors.red[500],
// //             onPressed: _setRatingAsTwo,
// //             iconSize: _size,
// //           ),
// //         ),
// //         Container(
// //           padding: EdgeInsets.all(0),
// //           child: IconButton(
// //             icon: (
// //                 _rating >= 3 ?
// //                 Icon(Icons.star, size: _size,)
// //                     : Icon(Icons.star_border, size: _size,)
// //             ),
// //             color: Colors.red[500],
// //             onPressed: _setRatingAsThree,
// //             iconSize: _size,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// // class ProductBox extends StatelessWidget {
// //   ProductBox({Key key, this.item}) : super(key: key);
// //   final Product item;
// //
// //   Widget build(BuildContext context) {
// //     return Container(
// //         padding: EdgeInsets.all(2), height: 140,
// //         child: Card(
// //           child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: <Widget>[
// //                 Image.asset("assets/appimages/" + this.item.image),
// //                 Expanded(
// //                     child: Container(
// //                         padding: EdgeInsets.all(5),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                           children: <Widget>[
// //                             Text(this.item.name, style:TextStyle(fontWeight: FontWeight.bold)),
// //                             Text(this.item.description),
// //                             Text("Price: " + this.item.price.toString()),
// //                             RatingBox(),
// //                           ],
// //                         )
// //                     )
// //                 )
// //               ]
// //           ),
// //         )
// //     );
// //   }
// // }
