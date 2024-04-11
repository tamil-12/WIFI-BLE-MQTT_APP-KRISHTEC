import 'package:flutter/material.dart';
import '../wifi_list_page.dart';
import 'scan_screen.dart';
import 'mqtt.dart';
import 'mqtt_wifi_connect.dart';

enum ConnectionOption {
  Bluetooth,
  Wifi,
  MQTT,
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ConnectionOption? _selectedOption; // Default selected option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Connect to a Device',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("images/img.jpg"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(0), // Adjust the border radius
                  ),
                ),
                const Positioned(
                  left: 16, // Adjust the left position
                  bottom: 16, // Adjust the bottom position
                  child: Text(
                    'KrishTec', // Display "Connect to a Device"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15), // Add space below the image
          DropdownButton<ConnectionOption>(
            value: _selectedOption,
            onChanged: (newValue) {
              setState(() {
                _selectedOption = newValue;
              });
            },
            hint: const Text('Select Mode'), // Show "Select Mode" if no option is chosen
            style: const TextStyle(color: Colors.black), // Customize dropdown text color
            underline: Container(), // Remove underline
            items: ConnectionOption.values.map((option) {
              return DropdownMenuItem<ConnectionOption>(
                value: option,
                child: Text(option.toString().split('.').last),
              );
            }).toList(),
          ),
          const SizedBox(height: 20), // Add space between the dropdown and buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             ElevatedButton(
                onPressed: _selectedOption != null ? _connect : null,
                style: ElevatedButton.styleFrom(
                backgroundColor:Colors.black,
                ),

                child: const Text('Connect',style: TextStyle(color: Colors.white)),
             ),
              if (_selectedOption == ConnectionOption.MQTT) ...[
                const SizedBox(width: 10),
                // Add space between the connect button and settings button
               ElevatedButton(

                  onPressed: () {
                    // Navigate to the MQTT settings screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MqttWifiScan()),
                    );
                  },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.black,
                 ),
                  child: const Text('Node Settings',style:TextStyle(color:Colors.white)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10), // Add some additional space
        ],
      ),
    );
  }

  void _connect() {
    switch (_selectedOption) {
      case ConnectionOption.Bluetooth:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BluetoothScanPage()),
        );
        break;
      case ConnectionOption.Wifi:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WifiListPage()),
        );
        break;
      case ConnectionOption.MQTT:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MqttPage()),
        );
        break;
      default:
      // Handle other cases or do nothing
        break;
    }
  }
}
