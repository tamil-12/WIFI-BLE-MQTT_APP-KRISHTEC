import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'mqtt_wifi.dart';
class MqttWifiScan extends StatefulWidget {
  const MqttWifiScan({super.key});

  @override
  _MqttWifiScanState createState() => _MqttWifiScanState();
}

class _MqttWifiScanState extends State<MqttWifiScan> {
  List<WifiNetwork> _networks = [];
  final TextEditingController _passwordController = TextEditingController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanWifiNetworks();
  }

  Future<void> _scanWifiNetworks() async {
    setState(() {
      _isScanning = true;
    });
    List<WifiNetwork> list = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _networks = list;
      _isScanning = false;
    });
  }

  Future<void> _connectToWifi(WifiNetwork network) async {
    String? password = await _showPasswordDialog();
    if (password != null) {
      bool isConnected = await _connectWithPassword(network, password);
      if (isConnected) {
        // Navigate to the WifiConnectedScreen only if connection is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MqttWifiScreen(
            ),
          ),
        );
      } else {
        // Display error message for wrong password and prompt to re-enter
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wrong Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter the correct password.'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _passwordController.text),
                child: const Text('Connect'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool> _connectWithPassword(WifiNetwork network, String password) async {
    try {
      await WiFiForIoTPlugin.connect(network.ssid!, password: password, security: NetworkSecurity.WPA);
      // Check for internet connectivity
      bool isConnected = await WiFiForIoTPlugin.isConnected();
      if (isConnected) {
        print('Connected to Wi-Fi network with internet access');
        return true; // Return true if connection is successful with internet access
      } else {
        print('Connected to Wi-Fi network, but no internet access');
        return false; // Return false if no internet access
      }
    } catch (e) {
      print('Connection failed: $e');
      return false; // Return false if connection fails
    }
  }

  Future<String?> _showPasswordDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _passwordController.text),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Networks'),
      ),
      body:ListView.builder(
        itemCount: _networks.length,
        itemBuilder: (context, index) {
          final network = _networks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi), // Wi-Fi symbol
                        const SizedBox(width: 10), // Adjusted padding
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox( // Added ConstrainedBox to set a maximum width for the network name text
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                              child: Text(network.ssid ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), // Network name
                            ),
                            const Text('Wi-Fi', style: TextStyle(fontSize: 12, color: Colors.black87)), // Wi-Fi text
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _connectToWifi(network),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Set connect button color to black
                      ),
                      child: const Text('Connect', style: TextStyle(color: Colors.white)), // Set text color to white
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Slider(
                  value: -(network.level?.toDouble() ?? 0), // Set range from 0 to -100
                  min: -100,
                  max: 100,
                  onChanged: (value) {},
                  activeColor: Colors.black, // Customize slider active color
                  inactiveColor: Colors.grey, // Customize slider inactive color
                ),
                const SizedBox(height: 2),
                Text('Strength: ${network.level}', style: const TextStyle(fontSize: 12, color: Colors.black87)), // Strength value
                const SizedBox(height: 8), // Added space after each device
                const Divider(color: Colors.black54), // Divider line
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : () {
          Timer(const Duration(seconds: 66), () {
            setState(() {
              _isScanning = false;
            });
          });
          _scanWifiNetworks();
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: _isScanning ? const CircularProgressIndicator() : const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
