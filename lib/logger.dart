import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'main.dart';

class Logger extends StatefulWidget { //logger is a stateful widget as homepage

  @override
  _LoggerState createState() => _LoggerState(); //usual declaration of a stateful widget
}

class _LoggerState extends State<Logger> {
  int selectedIndex = 1; //variable used in bottom navigation bar (as homepage)

  DateTime selectedDate = DateTime.now(); //get current time and date

  List<Map> data = List(); //declare a list of maps (used to get the json file from cloud service)

  @override
  void initState() { //actions exectued at the start of this widget
    getData(selectedDate.toString().substring(0, 10)); //function that get data from cloud services
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async { //function used to get date from datepicker
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2019, 11),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        this.getData(selectedDate.toString().substring(0, 10));
      });
  }

  void _onItemTapped(int index) { //function used to change view in bottom navigation bar
    setState(() {
      selectedIndex = index;
      if(selectedIndex == 0){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Temperature Logger')),
        );
      }
    });
  }

  Future<Null> getData(String datePicked) async { //function used to get data from cloud service
    final response = await http.get(
        'https://api.thingspeak.com/channels/902485/feeds.json?api_key=RBAIUDWXB1U2PAO7');
    setState(() {
      var resp = json.decode(response.body); //get a json object
      var feeds = resp["feeds"];
      if(data.isNotEmpty) {
        data.clear();
      }
      for(var elem in feeds) { //transforming and filtering json object
        var d = elem["created_at"];
        d = d.substring(0, 10);
        if(d == datePicked) { //filtering data according to selected date
          data.add(elem);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logger"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Selected date: "+selectedDate.toString().substring(0, 10)), //showing selected date from datepicker
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select date'), //button to confirm date selection
                  ),
                ],
              ),
          ),

          Expanded(
            child: ListView(
                children: <Widget>[
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable( //table used to show the data according to selected date
                        columns: [
                          DataColumn(label: Text("Time")),
                          DataColumn(label: Text("Temperature")),
                          DataColumn(label: Text("Humidity"))
                        ],
                        rows: data.map(
                          ((element) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(element["created_at"].substring(11, 19))), //Extracting from Map element the value
                              DataCell(Text(element["field1"])),
                              DataCell(Text(element["field2"])),
                            ],
                          )),
                        ).toList(),
                      ),
                  )
                ]
            ),
          )

        ],
      ),
      bottomNavigationBar: BottomNavigationBar( //this is the navigation bar in the bottom of application
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text('Logger'),
          ),

        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }

}