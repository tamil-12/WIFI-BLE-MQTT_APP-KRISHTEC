import 'dart:convert';
import 'dart:io';
import 'MqttConnectedPage.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttConfig {
  final String brokerUrl;
  final int port;
  final String topic;

  MqttConfig(this.brokerUrl, this.port, this.topic);

  factory MqttConfig.fromJson(Map<String, dynamic> json) {
    return MqttConfig(
      json['brokerUrl'] as String,
      json['port'] as int,
      json['topic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brokerUrl': brokerUrl,
      'port': port,
      'topic': topic,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MqttConfig &&
        other.brokerUrl == brokerUrl &&
        other.port == port &&
        other.topic == topic;
  }

  @override
  int get hashCode => brokerUrl.hashCode ^ port.hashCode ^ topic.hashCode;
}

class MqttPage extends StatefulWidget {
  const MqttPage({Key? key}) : super(key: key);

  @override
  _MqttPageState createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  late MqttServerClient client;
  String message = '';
  TextEditingController messageController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController brokerUrlController = TextEditingController();
  TextEditingController portController = TextEditingController();
  List<MqttConfig> mqttConfigs = [];

  @override
  void initState() {
    super.initState();
    loadSavedConfigs();
  }

  Future<void> loadSavedConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedConfigs = prefs.getStringList('mqtt_configs');

    if (savedConfigs != null) {
      setState(() {
        mqttConfigs = savedConfigs
            .map((configJson) => MqttConfig.fromJson(jsonDecode(configJson)))
            .toList();
      });
    }
  }

  Future<void> saveConfig(MqttConfig config) async {
    if (!mqttConfigs.contains(config)) {
      final prefs = await SharedPreferences.getInstance();
      mqttConfigs.add(config);
      prefs.setStringList(
          'mqtt_configs', mqttConfigs.map((c) => jsonEncode(c.toJson())).toList());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Configuration saved'),
      ));
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Duplicate configuration!'),
      ));
    }
  }

  Future<void> deleteConfig(int index) async {
    final prefs = await SharedPreferences.getInstance();
    mqttConfigs.removeAt(index);
    prefs.setStringList(
        'mqtt_configs', mqttConfigs.map((c) => jsonEncode(c.toJson())).toList());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Configuration deleted'),
    ));
    setState(() {});
  }

  Future<void> connectToMqtt(MqttConfig config) async {
    client = MqttServerClient(config.brokerUrl, '');
    client.port = config.port;
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MqttConnectedPage(client: client,topic: config.topic),
        ),
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
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add MQTT Configuration'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: brokerUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Enter MQTT Broker URL',
                        ),
                      ),
                      TextField(
                        controller: portController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Port',
                        ),
                      ),
                      TextField(
                        controller: topicController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Topic',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final config = MqttConfig(
                          brokerUrlController.text,
                          int.parse(portController.text),
                          topicController.text,
                        );
                        saveConfig(config);
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: mqttConfigs.length,
            itemBuilder: (context, index) {
              final config = mqttConfigs[index];
              return ListTile(
                title: Text(config.brokerUrl),
                subtitle: Text(
                    'Port: ${config.port}, Topic: ${config.topic}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.connect_without_contact),
                      onPressed: () {
                        connectToMqtt(config);
                      },
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteConfig(index);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
  }

  void onConnected() {
    print('OnConnected client callback - Client connection was successful');
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}

void main() {
  runApp(const MaterialApp(
    home: MqttPage(),
  ));
}
