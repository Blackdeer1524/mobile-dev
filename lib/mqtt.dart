import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'MQTT Messaging App',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: MqttAuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MqttAuthScreen extends StatefulWidget {
  @override
  _MqttAuthScreenState createState() => _MqttAuthScreenState();
}

class _MqttAuthScreenState extends State<MqttAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brokerController = TextEditingController();
  final _portController = TextEditingController();
  final _topicController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _brokerController.dispose();
    _portController.dispose();
    _topicController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _connectToMqtt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final client = MqttServerClient(_brokerController.text, '');
      client.port = int.parse(_portController.text);
      client.keepAlivePeriod = 20;
      client.autoReconnect = true;
      client.logging(on: true);

      // Set username if provided
      if (_usernameController.text.isNotEmpty) {
        client.setProtocolV311();
        client.autoReconnect = true;
        client.keepAlivePeriod = 20;
        client.logging(on: false);
        client.connectionMessage = MqttConnectMessage()
            .withClientIdentifier('')
            .withWillTopic('willtopic')
            .withWillMessage('My Will message')
            .startClean()
            .withWillQos(MqttQos.atLeastOnce);
      }

      // Connect to MQTT broker
      final connMessage = await client.connect();
      if (connMessage?.state == MqttConnectionState.connected) {
        // If connection successful, navigate to messaging screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => MqttMessagingScreen(
              client: client,
              broker: _brokerController.text,
              port: int.parse(_portController.text),
              topic: _topicController.text,
              username: _usernameController.text,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to MQTT broker';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('MQTT Authentication'),
        backgroundColor: CupertinoColors.systemBlue,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MQTT Connection',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              
                CupertinoTextField(
                  controller: _brokerController,
                  placeholder: 'Broker (e.g., test.mosquitto.org)',
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                SizedBox(height: 16),
                
                CupertinoTextField(
                  controller: _portController,
                  placeholder: 'Port (e.g., 1883)',
                  keyboardType: TextInputType.number,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                SizedBox(height: 16),
                
                CupertinoTextField(
                  controller: _topicController,
                  placeholder: 'Topic Name',
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                SizedBox(height: 16),
                
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Username (optional)',
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                SizedBox(height: 20),
                
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed.withOpacity(0.1),
                      border: Border.all(color: CupertinoColors.systemRed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: CupertinoColors.systemRed),
                    ),
                  ),
                
                SizedBox(height: 20),
                
                CupertinoButton.filled(
                  onPressed: _isLoading ? null : _connectToMqtt,
                  child: _isLoading
                      ? CupertinoActivityIndicator(color: CupertinoColors.white)
                      : Text(
                          'Connect to MQTT',
                          style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MqttMessagingScreen extends StatefulWidget {
  final MqttServerClient client;
  final String broker;
  final int port;
  final String topic;
  final String username;

  MqttMessagingScreen({
    required this.client,
    required this.broker,
    required this.port,
    required this.topic,
    required this.username,
  });

  @override
  _MqttMessagingScreenState createState() => _MqttMessagingScreenState();
}

class _MqttMessagingScreenState extends State<MqttMessagingScreen> {
  final _messageController = TextEditingController();
  final List<String> _receivedMessages = [];
  late StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> _subscription;
  
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _subscribeToTopic();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subscription.cancel();
    widget.client.disconnect();
    super.dispose();
  }

  void _subscribeToTopic() {
    try {
      widget.client.subscribe(widget.topic, MqttQos.atMostOnce);
      _subscription = widget.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        setState(() {
          _receivedMessages.insert(0, pt); // Add to beginning of list
        });
      });
      
      setState(() {
        _statusMessage = 'Subscribed to topic: ${widget.topic}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error subscribing: ${e.toString()}';
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepend username to message if provided
      String messageToSend = widget.username.isNotEmpty 
          ? '${widget.username}: ${_messageController.text}'
          : _messageController.text;

      final builder = MqttClientPayloadBuilder();
      builder.addString(messageToSend);
      
      widget.client.publishMessage(
        widget.topic,
        MqttQos.atMostOnce,
        builder.payload!,
      );

      setState(() {
        _statusMessage = 'Message sent successfully!';
        _messageController.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error sending message: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('MQTT Messaging'),
        backgroundColor: CupertinoColors.systemGreen,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: () {
            widget.client.disconnect();
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => MqttAuthScreen(),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Error') 
                      ? CupertinoColors.systemRed.withOpacity(0.1)
                      : CupertinoColors.systemGreen.withOpacity(0.1),
                  border: Border.all(
                    color: _statusMessage.contains('Error') 
                        ? CupertinoColors.systemRed 
                        : CupertinoColors.systemGreen,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error') 
                        ? CupertinoColors.systemRed 
                        : CupertinoColors.systemGreen,
                  ),
                ),
              ),
            
            // Message input section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Send Message',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  
                  CupertinoTextField(
                    controller: _messageController,
                    placeholder: 'Enter your message...',
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.separator),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  SizedBox(height: 16),
                  
                  CupertinoButton.filled(
                    onPressed: _isLoading ? null : _sendMessage,
                    child: _isLoading
                        ? CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Text(
                            'Send Message',
                            style: TextStyle(fontSize: 16, color: CupertinoColors.white),
                          ),
                  ),
                ],
              ),
            ),
            
            // Received messages section
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Received Messages',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _receivedMessages.isEmpty
                          ? Center(
                              child: Text(
                                'No messages received yet',
                                style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _receivedMessages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: CupertinoColors.separator),
                                  ),
                                  child: Text(
                                    _receivedMessages[index],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
