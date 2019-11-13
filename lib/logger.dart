import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'main.dart';

class Logger extends StatefulWidget {

  @override
  _LoggerState createState() => _LoggerState();
}

class _LoggerState extends State<Logger> {
  int selectedIndex = 1;

  DateTime selectedDate = DateTime.now();

  List<Map> data = List();

  @override
  void initState() {
    getData(selectedDate.toString().substring(0, 10));
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
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

  void _onItemTapped(int index) {
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

  Future<Null> getData(String datePicked) async{
    final response = await http.get(
        'https://api.thingspeak.com/channels/902485/feeds.json?api_key=RBAIUDWXB1U2PAO7');
    setState(() {
      var resp = json.decode(response.body);
      var feeds = resp["feeds"];
      if(data.isNotEmpty) {
        data.clear();
      }
      for(var elem in feeds) {
        var d = elem["created_at"];
        d = d.substring(0, 10);
        if(d == datePicked) {
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
                  //Text("${selectedDate.toLocal()}"),
                  Text("Selected date: "+selectedDate.toString().substring(0, 10)),
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select date'),
                  ),
                ],
              ),
          ),


          Expanded(
            child: ListView(
                children: <Widget>[
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
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


          /*Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Hour")),
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
          ),*/

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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