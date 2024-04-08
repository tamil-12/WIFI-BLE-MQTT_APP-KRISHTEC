import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mqtt_configure.dart';

class MqttWifiScreen extends StatefulWidget {
  const MqttWifiScreen({super.key});

  @override
  _MqttWifiScreenState createState() => _MqttWifiScreenState();
}

class _MqttWifiScreenState extends State<MqttWifiScreen> {
  List<String> availableNetworks = [];
  String wifiStatus = '';
  bool _isLoading = true; // Track whether data is being fetched

  @override
  void initState() {
    super.initState();
    _fetchAvailableNetworks();
    _fetchWifiStatus();
  }

  Future<void> _fetchAvailableNetworks() async {
    try {
      setState(() {
        _isLoading = true; // Set isLoading to true when fetching data
      });
      final response = await http.get(Uri.parse('http://192.168.1.1/scan-wifi'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          availableNetworks = List<String>.from(data);
          _isLoading = false; // Data fetched, set isLoading to false
        });
      } else {
        throw Exception('Failed to load available networks');
      }
    } catch (e) {
      print('Error fetching available networks: $e');
    }
  }

  Future<void> _sendDataToESP32(String ssid, String password) async {
    try {
      String url = 'http://192.168.1.1/connect-to-wifi';
      Map<String, String> data = {'ssid': ssid, 'password': password};

      String jsonData = json.encode(data);
      Map<String, String> headers = {'Content-Type': 'application/json'};

      await http.post(Uri.parse(url), headers: headers, body: jsonData);
      _fetchWifiStatus(); // Fetch Wi-Fi status after connecting
    } catch (e) {
      print('Error sending data to ESP32: $e');
    }
  }

  Future<void> _fetchWifiStatus() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.1/wifi-status'));
      if (response.statusCode == 200) {
        setState(() {
          wifiStatus = response.body;
        });
        _showResultDialog();
      } else {
        throw Exception('Failed to fetch Wi-Fi status');
      }
    } catch (e) {
      print('Error fetching Wi-Fi status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Selection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAvailableNetworks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please disconnect and reconnect the device WiFi in settings',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: availableNetworks.length,
              itemBuilder: (context, index) {
                final ssid = availableNetworks[index];
                return ListTile(
                  title: Text(ssid),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showPasswordDialog(ssid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text('Connect',style: TextStyle(color: Colors.white),),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPasswordDialog(String ssid) async {
    String password = '';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black
              ),
              child: const Text('Cancel',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                _sendDataToESP32(ssid, password);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text('Connect',style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResultDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wi-Fi Connection Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(wifiStatus),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the MQTT settings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MqttConfigure()),
                  );
                },
                child: const Text('Edit MQTT'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
