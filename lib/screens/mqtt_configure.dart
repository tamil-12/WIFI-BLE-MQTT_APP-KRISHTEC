import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MqttConfigure extends StatefulWidget {
  const MqttConfigure({super.key});

  @override
  _MqttConfigureState createState() => _MqttConfigureState();
}

class _MqttConfigureState extends State<MqttConfigure> {
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure MQTT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(labelText: 'MQTT Server'),
            ),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'MQTT Port'),
            ),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: 'MQTT Topic'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveMqttConfiguration();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMqttConfiguration() async {
    final server = _serverController.text.trim();
    final port = _portController.text.trim();
    final topic = _topicController.text.trim();

    // Validate input fields
    if (server.isEmpty || port.isEmpty || topic.isEmpty) {
      _showErrorDialog('Please fill all fields');
      return;
    }

    // Send MQTT configuration data to ESP32
    const url = 'http://192.168.1.1/save-mqtt-config';
    final data = {
      'server': server,
      'port': port,
      'topic': topic,
    };

    try {
      // Send MQTT configuration data to ESP32 and wait for a response
      final response = await _sendConfigurationToESP(url, data);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        throw Exception('Failed to save MQTT configuration');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  Future<http.Response> _sendConfigurationToESP(String url, Map<String, dynamic> data) async {
    // Send MQTT configuration data to ESP32
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('MQTT configuration saved successfully'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _topicController.dispose();
    super.dispose();
  }
}
