import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
class ControlPage extends StatefulWidget {
  final BluetoothService service;

  const ControlPage({super.key, required this.service});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  List<BluetoothCharacteristic> _characteristics = [];
  String _serviceUuid = '';

  @override
  void initState() {
    super.initState();
    _serviceUuid = widget.service.uuid.toString();
    _characteristics = widget.service.characteristics;
  }

  Future<void> _readCharacteristics() async {
    for (BluetoothCharacteristic characteristic in _characteristics) {
      List<int> value;
      try {
        value = await characteristic.read();
        print('Characteristic value for ${characteristic.uuid}: $value');
      } catch (e) {
        print('Error reading characteristic ${characteristic.uuid}: $e');
      }
    }
  }

  Future<void> _sendHiMessage() async {
    final hiMessage = utf8.encode('hi');
    for (BluetoothCharacteristic characteristic in _characteristics) {
      try {
        await characteristic.write(hiMessage);
        print('Sent "hi" message to ${characteristic.uuid}');
      } catch (e) {
        print('Error sending "hi" message to ${characteristic.uuid}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Service UUID: $_serviceUuid'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _readCharacteristics,
              child: const Text('Read Characteristics'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendHiMessage,
              child: const Text('Send "hi" Message'),
            ),
          ],
        ),
      ),
    );
  }
}
