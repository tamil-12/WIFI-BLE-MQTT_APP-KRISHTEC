import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

class MqttPage extends StatefulWidget {
  const MqttPage({super.key});

  @override
  _MqttPageState createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  late MqttServerClient client;
  bool connected = false;
  String message = '';
  String? customTopic;
  TextEditingController messageController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController brokerUrlController = TextEditingController();
  TextEditingController portController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void connectToMqtt() async {
    client = MqttServerClient(brokerUrlController.text, '');
    client.port = int.tryParse(portController.text) ?? 1883; // Default port is 1883
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('dart_client')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('Client exception: $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Client connected');
      setState(() {
        connected = true;
      });
      // Navigate to the new page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TopicMessagePage(client: client)),
      );
    } else {
      print(
          'Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String payload =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        message = payload;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'MQTT Status: ${connected ? "Connected" : "Disconnected"}',
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: brokerUrlController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter MQTT Broker URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Port',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (connected) {
                    disconnectFromMqtt();
                  } else {
                    connectToMqtt();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
                ),
                child: Text('${connected ? 'Disconnect' : 'Connect'} to MQTT Broker',style: const TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void disconnectFromMqtt() {
    client.disconnect();
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    setState(() {
      connected = false;
    });
  }

  void onConnected() {
    print('OnConnected client callback - Client connection was successful');
    setState(() {
      connected = true;
    });
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}

class TopicMessagePage extends StatefulWidget {
  final MqttServerClient client;

  const TopicMessagePage({super.key, required this.client});

  @override
  _TopicMessagePageState createState() => _TopicMessagePageState();
}

class _TopicMessagePageState extends State<TopicMessagePage> {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool messageSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic and Message'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: 'Enter Topic Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Enter Message',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Publish the message
                publishMessage(topicController.text, messageController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black
              ),
              child: const Text('Publish Message',style: TextStyle(color: Colors.white),),
            ),

            const SizedBox(height: 20),
            messageSent ? const Text('Message sent successfully!') : Container(),
          ],
        ),
      ),
    );
  }

  void publishMessage(String topic, String message) {
    widget.client.publishMessage(topic, MqttQos.exactlyOnce, MqttClientPayloadBuilder().addString(message).payload!);
    setState(() {
      messageSent = true;
    });
  }
}

void main() {
  runApp(const MaterialApp(
    home: MqttPage(),
  ));
}
