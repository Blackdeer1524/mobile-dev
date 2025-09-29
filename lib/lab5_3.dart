import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class IoControlWS extends StatefulWidget {
  const IoControlWS();
  @override
  State<IoControlWS> createState() => _IoControlWSState();
}

class _IoControlWSState extends State<IoControlWS> {
  WebSocket? _socket;
  bool _connecting = false;
  bool _connected = false;
  int _isTurnedOn = 0;
  int _sliderValue = 0;
  String _status = 'disconnected';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (_connecting || _connected) return;
    setState(() {
      _connecting = true;
      _status = 'connecting…';
    });
    try {
      final uri = Uri.parse('ws://185.102.139.168:8198');
      final socket = await WebSocket.connect(uri.toString());
      _socket = socket;
      _connected = true;
      setState(() {
        _status = 'connected';
      });

      socket.listen(
        _onMessage,
        onDone: _onDone,
        onError: (e) {
          _onError('socket error: $e');
        },
        cancelOnError: true,
      );

      // 1) Ask if device is on
      _send({"action": "isOn"});
    } catch (e) {
      _onError('connect failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _connecting = false;
        });
      }
    }
  }

  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> msg = json.decode(data as String);
      final String? type = msg['type'] as String?; // optional discriminator
      if (msg.containsKey('isOn')) {
        final int isOn = int.parse(msg['isOn'].toString());
        setState(() {
          _isTurnedOn = isOn;
        });
        if (isOn == 1) {
          // 2) If device is on, request slider
          _send({"action": "getSlider"});
        }
      }
      if (msg.containsKey('slider')) {
        final int slider = int.parse(msg['slider'].toString());
        setState(() {
          _sliderValue = slider;
        });
      }
      if (type == 'status' && msg['message'] is String) {
        setState(() {
          _status = msg['message'] as String;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('WS parse error: $e, data: $data');
    }
  }

  void _onDone() {
    _connected = false;
    _socket = null;
    if (mounted) {
      setState(() {
        _status = 'disconnected';
      });
    }
  }

  void _onError(String message) {
    _connected = false;
    _socket = null;
    if (mounted) {
      setState(() {
        _status = message;
      });
    }
  }

  void _send(Map<String, dynamic> jsonMsg) {
    if (_socket == null) return;
    _socket!.add(json.encode(jsonMsg));
  }

  void _turnOn() {
    _send({"action": "turnOn"});
    // after turning on, request current slider value
    _send({"action": "getSlider"});
  }

  void _turnOff() {
    _send({"action": "turnOff"});
  }

  void _setSliderWS(int v) {
    if (_isTurnedOn == 0) return;
    _send({"action": "setSlider", "value": v});
    setState(() {
      _sliderValue = v;
    });
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Device Control (WebSocket)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            CupertinoButton(
              onPressed: _connected || _connecting ? null : _connect,
              child: const Text('Reconnect'),
            ),
            const SizedBox(width: 12),
            Text(_status),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            (_isTurnedOn == 1)
                ? CupertinoButton.filled(
                    onPressed: _turnOn,
                    child: const Text('ON'),
                  )
                : CupertinoButton(
                    onPressed: _turnOn,
                    child: const Text('ON'),
                  ),
            const SizedBox(width: 12),
            (_isTurnedOn == 0)
                ? CupertinoButton.filled(
                    onPressed: _turnOff,
                    child: const Text('OFF'),
                  )
                : CupertinoButton(
                    onPressed: _turnOff,
                    child: const Text('OFF'),
                  ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            CupertinoButton(
              onPressed: () => _setSliderWS(0),
              child: const Text('reset'),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              onPressed:
                  _isTurnedOn == 1 ? () => _setSliderWS(_sliderValue + 10) : null,
              child: const Text('+'),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              onPressed:
                  _isTurnedOn == 1 ? () => _setSliderWS(_sliderValue - 10) : null,
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
                onChanged: _isTurnedOn == 1
                    ? (v) => _setSliderWS(v.round())
                    : null,
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
