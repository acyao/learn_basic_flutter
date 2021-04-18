import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', storage: CounterStorage()),
    );
  }
}


class CounterStorage {
  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async{
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async{
    try {
      final file = await _localFile; 

      String contents = await file.readAsString();
      
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async{
    final file = await _localFile;

    return file.writeAsString('$counter');
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final CounterStorage storage;

  MyHomePage({Key? key, required this.title, required this.storage}) : super(key: key);



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _counter;

  @override 
  void initState(){
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }

  Future<File> _incrementCounter() async{
    setState(() {
     
      _counter++;
    });

    return widget.storage.writeCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new ListView.builder(
        itemCount: _counter,
        itemBuilder: (context, index){
            return ListTile(
              leading: const Icon(FontAwesomeIcons.book),
              title: Text('Name of item'),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:  (context) => SecondPage()),
                );
              },
            ); 
          },
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SecondPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Text('Second Screen'),
    ),
    body: Center(
      child: ElevatedButton.icon(
        onPressed: (){
          Navigator.push(context,
          MaterialPageRoute(builder:  (context) => ThirdPage()),);
        },
        label: Text('Go next page'),
        icon: new Icon(FontAwesomeIcons.stepForward),
        // onPressed: (){
        //   Navigator.pop(context);
        // },
        // label: Text('Go Back!'),
        // icon: new Icon(FontAwesomeIcons.stepBackward),
        
      ),
      ),
    );
  }
}

class GetData{
  Future<http.Response> fetchData(http.Client client) async{
    return client.get(Uri.https('jsonplaceholder.typicode.com','photos'));
  }
}

// Future<http.Response> fetchAlbum() {
//   return http.get(Uri.https('jsonplaceholder.typicode.com', 'albums/1'));
// }


Future<Album> fetchAlbum() async {
  final response =
      await http.get(Uri.https('jsonplaceholder.typicode.com', 'albums/1'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({required this.userId, required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}


class ThirdPage extends StatefulWidget {
  ThirdPage({Key? key}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.title);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}