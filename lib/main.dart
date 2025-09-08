import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // <----- Step 1
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var isTurnedOn = 0;
  try {
    final flagUri = Uri.parse(
      "http://iocontrol.ru/api/readData/slesarevdaiu9/aaa",
    );
    var res = await http.get(flagUri);
    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      isTurnedOn = int.parse(jsonData['value']);
      print("Startup response value: $isTurnedOn");
    }
  } catch (error) {
    print("Startup GET error: $error");
  }
  runApp(MyApp(isTurnedOn));
}

class MyApp extends StatelessWidget {
  int _value;
  MyApp(int value, {Key? key}) : _value = value, super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(_value, title: 'ТЕСТ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(int isTurnedOn, {Key? key, required this.title})
    : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _isTurnedOn = 0;
  int _sliderValue = 0;
  void _getDeviceRequestON() {
    setState(() {
      http
          .get(
            Uri.parse("http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/1"),
          )
          .then((response) {
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
            _isTurnedOn = 1;
          })
          .catchError((error) {
            print("Error: $error");
          });
      http
          .get(
            Uri.parse("http://iocontrol.ru/api/readData/slesarevdaiu9/slider"),
          )
          .then((response) {
            final jsonData = json.decode(response.body);
            _sliderValue = int.parse(jsonData["value"]);
          })
          .catchError((error) {
            print("Error: $error");
          });
    });
  }

  void _getRequestOFF() {
    if (_isTurnedOn == 0) {
      return;
    }
    setState(() {
      http
          .get(
            Uri.parse("http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/0"),
          )
          .then((response) {
            _isTurnedOn = 0;
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
          })
          .catchError((error) {
            print("Error: $error");
          });
    });
  }

  void _reset_slider() {
    if (_isTurnedOn == 0) {
      return;
    }

    setState(() {
      http
          .get(
            Uri.parse(
              "http://iocontrol.ru/api/sendData/slesarevdaiu9/slider/0",
            ),
          )
          .then((response) {
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
            _sliderValue = 0;
          })
          .catchError((error) {
            print("Error: $error");
          });
    });
  }

  void _increment_slider() {
    if (_isTurnedOn == 0) {
      return;
    }

    setState(() {
      http
          .get(
            Uri.parse(
              "http://iocontrol.ru/api/sendData/slesarevdaiu9/slider/${_sliderValue + 10}",
            ),
          )
          .then((response) {
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
            _sliderValue += 10;
          })
          .catchError((error) {
            print("Error: $error");
          });
    });
  }

  void _decrement_slider() {
    if (_isTurnedOn == 0) {
      return;
    }

    setState(() {
      http
          .get(
            Uri.parse(
              "http://iocontrol.ru/api/sendData/slesarevdaiu9/slider/${_sliderValue - 10}",
            ),
          )
          .then((response) {
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
            _sliderValue -= 10;
          })
          .catchError((error) {
            print("Error: $error");
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: _getDeviceRequestON,
              child: Text('ON'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: _getRequestOFF,
              child: Text('OFF'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: _increment_slider,
              child: Text('+'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: _decrement_slider,
              child: Text('-'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: _reset_slider,
              child: Text('reset'),
            ),
          ],
        ),
      ),
    );
  }
}
