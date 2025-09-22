import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IoControlWorkOnOff extends StatefulWidget {
  const IoControlWorkOnOff();
  @override
  State<IoControlWorkOnOff> createState() => _IoControlWorkOnOffState();
}

class _IoControlWorkOnOffState extends State<IoControlWorkOnOff> {
  int _isTurnedOn = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    try {
      final deviceUri = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/aaa',
      );
      final deviceRes = await http.get(deviceUri);
      final deviceJson = json.decode(deviceRes.body);
      final int isOn = int.parse(deviceJson['value'].toString());

      if (!mounted) return;
      setState(() {
        _isTurnedOn = isOn;
      });
    } catch (e) {
      print('Initial state load error: $e');
    }
  }

  Future<void> _getDeviceRequestON() async {
    try {
      final onUri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/1',
      );
      await http.get(onUri);
      setState(() {
        _isTurnedOn = 1;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Turn ON or read slider error: $e');
    }
  }

  Future<void> _getRequestOFF() async {
    if (_isTurnedOn == 0) return;
    try {
      final offUri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/0',
      );
      await http.get(offUri);
      setState(() {
        _isTurnedOn = 0;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Turn OFF error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Device Control (HTTP)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            (_isTurnedOn == 1)
                ? CupertinoButton.filled(
                    onPressed: _getDeviceRequestON,
                    child: const Text('ON'),
                  )
                : CupertinoButton(
                    onPressed: _getDeviceRequestON,
                    child: const Text('ON'),
                  ),
            const SizedBox(width: 12),
            (_isTurnedOn == 0)
                ? CupertinoButton.filled(
                    onPressed: _getRequestOFF,
                    child: const Text('OFF'),
                  )
                : CupertinoButton(
                    onPressed: _getRequestOFF,
                    child: const Text('OFF'),
                  ),
          ],
        ),
      ],
    );
  }
}
