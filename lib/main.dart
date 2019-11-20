import 'package:flutter/material.dart'; //library for material design in flutter
import 'package:http/http.dart' as http; //library to make http requests
import 'dart:async'; //library to do async functions
import 'dart:convert'; //library to convert data structures in flutter
import 'logger.dart'; //logger page imported

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Logger',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Temperature Logger'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String latestTemp = ""; //global variable used to get latest temperature detected
  String latestHum = ""; //global variable used to get latest humidity detected
  String latestDate = ""; //global variable used to get latest recognition date
  String latestHour = ""; //global variable used to get latest recognition time

  @override
  void initState() { //function executed at start of this widget
    refresh();
    super.initState();
  }

  Future<Null> refresh() async { //function that get information from cloud service and update variables in this application
    final response = await http.get(
                        'https://api.thingspeak.com/channels/902485/feeds.json?api_key=RBAIUDWXB1U2PAO7&results=1'); //http request to get latest values from cloud service
    setState(() { //updating state and variables
      var resp = json.decode(response.body); //transforming json object
      var feeds = resp["feeds"];
      latestTemp = feeds[0]["field1"]; //updating variables
      latestHum = feeds[0]["field2"];
      var latestRecognition = feeds[0]["created_at"];
      latestDate = latestRecognition.substring(0, 10);
      latestHour = latestRecognition.substring(11, 19);
    });
  }

  int selectedIndex = 0; //variables used for bottom navigation bar
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);


  void _onItemTapped(int index) { //actions executed when bottom navigation bar is tapped
    setState(() {
      selectedIndex = index;
      if(selectedIndex == 1){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Logger()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) { //this is the graphical part
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card( //Widget used to show latest temperature detected
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Temperature",
                            style: new TextStyle(fontSize: 25.0),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              latestTemp+" °C",
                              style: new TextStyle(fontSize: 15.0),
                            )
                        ),
                      ],
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card( //Widget used to show latest humidity detected
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Humidity",
                            style: new TextStyle(fontSize: 25.0),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              latestHum+" %",
                              style: new TextStyle(fontSize: 15.0),
                            )
                        ),
                      ],
                    )
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Latest recognition: "+latestDate+" at "+latestHour), //here latest date and time is shown
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RaisedButton(
              child: Text("Refresh"),
              onPressed: () {
                  refresh(); //refresh button call refresh function
              },
            ),
          ),
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
