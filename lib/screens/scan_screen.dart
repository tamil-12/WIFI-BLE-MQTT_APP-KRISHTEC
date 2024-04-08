// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:snowcounter/screens/connected_screen.dart';
//
// class BluetoothScanPage extends StatefulWidget {
//   @override
//   _BluetoothScanPageState createState() => _BluetoothScanPageState();
// }
//
// class _BluetoothScanPageState extends State<BluetoothScanPage> {
//   final flutterReactiveBle = FlutterReactiveBle();
//   List<DiscoveredDevice> discoveredDevices = [];
//   Map<String, bool> connectedDevices = {};
//
//   bool isScanning = false;
//
//   StreamSubscription? scanSubscription;
//
//   @override
//   void dispose() {
//     scanSubscription?.cancel();
//     super.dispose();
//   }
//
//   Future<void> scanForDevices() async {
//     setState(() {
//       isScanning = true;
//       discoveredDevices.clear(); // Clear existing devices before scanning
//     });
//
//     try {
//       scanSubscription = flutterReactiveBle
//           .scanForDevices(withServices: [])
//           .listen((device) {
//         if (mounted) { // Check if the widget is still mounted
//           setState(() {
//             if (!discoveredDevices.any((element) => element.id == device.id) &&
//                 device.name != null) {
//               discoveredDevices.add(device);
//               connectedDevices[device.id] =
//               false; // Initialize as not connected
//             }
//           });
//         }
//       }, onError: (dynamic error) {
//         print('Error during scanning: $error');
//         if (mounted) { // Check if the widget is still mounted
//           setState(() {
//             isScanning = false;
//           });
//         }
//       }, onDone: () {
//         if (mounted) { // Check if the widget is still mounted
//           setState(() {
//             isScanning = false;
//           });
//         }
//       });
//
//       // Stop scanning after 6 seconds
//       Timer(Duration(seconds: 6), () {
//         if (isScanning && mounted) { // Check if the widget is still mounted
//           scanSubscription?.cancel();
//           setState(() {
//             isScanning = false;
//           });
//         }
//       });
//     } catch (e) {
//       print('Error during scanning: $e');
//       if (mounted) { // Check if the widget is still mounted
//         setState(() {
//           isScanning = false;
//         });
//       }
//     }
//   }
//
//   Future<void> connectToDevice(DiscoveredDevice device) async {
//     try {
//       await flutterReactiveBle
//           .connectToDevice(
//         id: device.id,
//         servicesWithCharacteristicsToDiscover: {},
//         connectionTimeout: const Duration(seconds: 2),
//       )
//           .first;
//       print('Connected to ${device.name}');
//       setState(() {
//         connectedDevices[device.id] = true; // Mark as connected
//       });
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ConnectedPage(
//             deviceId: device.id,
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error connecting to ${device.name}: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Mode'),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: isScanning ? null : scanForDevices,
//             child: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
//           ),
//           SizedBox(height: 10),
//           Expanded(
//             child: ListView.builder(
//               itemCount: discoveredDevices.isEmpty ? 1 : discoveredDevices.length,
//               itemBuilder: (context, index) {
//                 if (discoveredDevices.isEmpty) {
//                   // Display a message when no devices are found
//                   return Center(
//                     child: Text('No devices found'),
//                   );
//                 } else {
//                   final device = discoveredDevices[index];
//                   if (device.name != null) {
//                     return ListTile(
//                       title: Text(device.name!),
//                       subtitle: Text(device.id),
//                       trailing: ElevatedButton(
//                         onPressed: connectedDevices[device.id] == true
//                             ? null
//                             : () => connectToDevice(device),
//                         child: Text(
//                           connectedDevices[device.id] == true
//                               ? 'Connected'
//                               : 'Connect',
//                         ),
//                       ),
//                     );
//                   } else {
//                     // Return an empty container if device name is null
//                     return Container();
//                   }
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:snowcounter/screens/connected_screen.dart';

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({super.key});

  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> discoveredDevices = [];
  Map<String, bool> connectedDevices = {};

  bool isScanning = false;

  StreamSubscription? scanSubscription;

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }

  Future<void> scanForDevices() async {
    setState(() {
      isScanning = true;
      discoveredDevices.clear(); // Clear existing devices before scanning
    });

    try {
      scanSubscription = flutterReactiveBle
          .scanForDevices(withServices: [])
          .listen((device) {
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            if (!discoveredDevices.any((element) => element.id == device.id)) {
              discoveredDevices.add(device);
              connectedDevices[device.id] =
              false; // Initialize as not connected
            }
          });
        }
      }, onError: (dynamic error) {
        print('Error during scanning: $error');
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            isScanning = false;
          });
        }
      }, onDone: () {
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            isScanning = false;
          });
        }
      });

      // Stop scanning after 6 seconds
      Timer(const Duration(seconds: 5), () {
        if (isScanning && mounted) { // Check if the widget is still mounted
          scanSubscription?.cancel();
          setState(() {
            isScanning = false;
          });
        }
      });
    } catch (e) {
      print('Error during scanning: $e');
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  Future<void> connectToDevice(DiscoveredDevice device) async {
    try {
      await flutterReactiveBle
          .connectToDevice(
        id: device.id,
        servicesWithCharacteristicsToDiscover: {},
        connectionTimeout: const Duration(seconds: 2),
      )
          .first;
      print('Connected to ${device.name}');
      setState(() {
        connectedDevices[device.id] = true; // Mark as connected
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectedPage(
            deviceId: device.id,
          ),
        ),
      );
    } catch (e) {
      print('Error connecting to ${device.name}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Mode'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : scanForDevices,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Set background color to black
            ),

            child: Text(isScanning ? 'Scanning...' : 'Scan for Devices',style:const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                final device = discoveredDevices[index];
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          const Icon(Icons.bluetooth, color: Colors.black54), // Bluetooth icon
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(device.name ?? 'Unnamed Device', style: const TextStyle(color: Colors.black87)), // Device name or 'Unnamed Device'
                              const Text('Bluetooth', style: TextStyle(color: Colors.black54)), // Bluetooth text
                            ],
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Slider(
                            value: device.rssi != null ? device.rssi.toDouble() : 0, // Convert int to double
                            onChanged: (double value) {}, // Placeholder onChanged function
                            min: -200, // Min signal strength
                            max: 0, // Max signal strength
                            activeColor: Colors.black, // Slider active color
                            inactiveColor: Colors.grey, // Slider inactive color
                          ),
                          Text(
                            'RSSI: ${device.rssi != null ? "${device.rssi} dBm" : "N/A"}', // Display RSSI value with dBm units below the slider
                            style: const TextStyle(color: Colors.black87), // Set text color to black
                          ),

                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: connectedDevices[device.id] == true
                            ? null
                            : () => connectToDevice(device),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black), // Set connect button background color to black
                        ),
                        child: Text(
                          connectedDevices[device.id] == true ? 'Connected' : 'Connect',
                          style: const TextStyle(color: Colors.white), // Set connect text color to white
                        ),
                      ),
                    ),
                    const Divider(color: Colors.black), // Divider line
                  ],
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}



