import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IoControlWork extends StatefulWidget {
  const IoControlWork();
  @override
  State<IoControlWork> createState() => _IoControlWorkState();
}

class _IoControlWorkState extends State<IoControlWork> {
  int _isTurnedOn = 0;
  int _sliderValue = 0;

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

      final sliderUri = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/slider',
      );
      final sliderRes = await http.get(sliderUri);
      final sliderJson = json.decode(sliderRes.body);
      final int slider = int.parse(sliderJson['value'].toString());

      if (!mounted) return;
      setState(() {
        _isTurnedOn = isOn;
        _sliderValue = slider;
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
      final readSlider = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/slider',
      );
      final sliderRes = await http.get(readSlider);
      final jsonData = json.decode(sliderRes.body);
      setState(() {
        _sliderValue = int.parse(jsonData['value'].toString());
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

  Future<void> _setSlider(int v) async {
    if (_isTurnedOn == 0) return;
    try {
      final uri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/slider/$v',
      );
      await http.get(uri);
      setState(() {
        _sliderValue = v;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Set slider error: $e');
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
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            CupertinoButton(
              onPressed: () => _setSlider(0),
              child: const Text('reset'),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              onPressed: () => _setSlider(_sliderValue + 10),
              child: const Text('+'),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              onPressed: () => _setSlider(_sliderValue - 10),
              child: const Text('-'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoSlider(
                value: _sliderValue.toDouble(),
                min: 0,
                max: 100,
                onChanged: (v) => _setSlider(v.round()),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text('$_sliderValue', textAlign: TextAlign.end),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('State: ${_isTurnedOn == 1 ? 'ON' : 'OFF'}'),
      ],
    );
  }
}
