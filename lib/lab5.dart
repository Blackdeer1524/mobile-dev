import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class CloudComputer extends StatefulWidget {
  const CloudComputer({Key? key}) : super(key: key);

  @override
  State<CloudComputer> createState() => _CloudComputerState();
}

class _CloudComputerState extends State<CloudComputer> {
  final _aVarText = TextEditingController();
  final _bVarText = TextEditingController();

  double computedValue = 0.0;
  double sliderValue = 0.0;
  WebSocket? _socket;
  String _connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  Future<void> _connectToWebSocket() async {
    try {
      _socket = await WebSocket.connect('ws://185.102.139.168:8197');
      setState(() {
        _connectionStatus = 'Connected';
      });

      _socket!.listen(
        (data) {
          final response = jsonDecode(data);
          print(response);
          if (response['type'] == 'ok') {
            if (response['result'] != null) {
              setState(() {
                computedValue = response['result'].toDouble();
              });
            } else if (response["value"] != null) {
              setState(() {
                sliderValue = response["value"].toDouble();
              });
            }
          }
        },
        onError: (error) {
          setState(() {
            _connectionStatus = 'Error: $error';
          });
        },
        onDone: () {
          setState(() {
            _connectionStatus = 'Disconnected';
          });
        },
      );

      _loadSliderVal();
    } catch (e) {
      setState(() {
        _connectionStatus = 'Failed to connect: $e';
      });
    }
  }

  void _loadSliderVal() {
    if (_socket == null) {
      _connectToWebSocket();
      return;
    }

    final message = jsonEncode({'action': 'load'});
    _socket!.add(message);
  }

  void _sendSliderVal(double val) {
    if (_socket == null) {
      _connectToWebSocket();
      return;
    }

    final message = jsonEncode({'action': 'store', 'value': sliderValue});
    _socket!.add(message);
  }

  void _sendArithOperation(String action) {
    if (_socket == null) {
      _connectToWebSocket();
      return;
    }

    final aVal = double.tryParse(_aVarText.text) ?? 0.0;
    final bVal = double.tryParse(_bVarText.text) ?? 0.0;

    final message = jsonEncode({'action': action, 'a': aVal, 'b': bVal});

    _socket!.add(message);
  }

  @override
  void dispose() {
    _aVarText.dispose();
    _bVarText.dispose();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Status: $_connectionStatus'),
            Text(computedValue.toString()),
            CupertinoTextField(controller: _aVarText, placeholder: '0.0'),
            CupertinoTextField(controller: _bVarText, placeholder: '0.0'),
            Row(
              children: [
                CupertinoButton.filled(
                  onPressed: () => _sendArithOperation('add'),
                  child: const Text('add'),
                ),
                CupertinoButton.filled(
                  onPressed: () => _sendArithOperation('sub'),
                  child: const Text('sub'),
                ),
                CupertinoButton.filled(
                  onPressed: () => _sendArithOperation('mul'),
                  child: const Text('mult'),
                ),
                CupertinoButton.filled(
                  onPressed: () => _sendArithOperation('div'),
                  child: const Text('div'),
                ),
              ],
            ),
            CupertinoSlider(
              value: sliderValue,
              onChanged: (newValue) {
                setState(() {
                  sliderValue = newValue;
                  _sendSliderVal(newValue);
                  // _sendArithOperation("add");
                });
              },
              min: 0.0,
              max: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}
