import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;

class WifiConnectedScreen extends StatefulWidget {
  final WifiNetwork connectedNetwork;

  const WifiConnectedScreen({super.key, required this.connectedNetwork});

  @override
  _WifiConnectedScreenState createState() => _WifiConnectedScreenState();
}

class _WifiConnectedScreenState extends State<WifiConnectedScreen> {
  final double _gaugeValue = 0; // Variable to hold gauge value
  double _sliderValue = 0; // Variable to hold slider value
  final double _minSliderValue = 0; // Minimum range for slider
  final double _maxSliderValue = 100; // Maximum range for slider
  final List<ItemModel> _items = []; // List to hold selected options
  bool _isSwitchOn = false; // Variable to hold switch state
  final bool _isDisconnected = false;

  set _isConnected(bool isConnected) {} // Variable to track disconnection status

  @override
  void initState() {
    super.initState();
  }
  Future<void> _sendData(String action) async {
    try {
      String url = 'http://192.168.1.1/send-data'; // Assuming ipAddress is the ESP32's IP
      Map<String, String> data = {'action': action};

      // Convert the data map to a JSON string
      String jsonData = json.encode(data);

      // Set the headers to indicate that the request body contains JSON data
      Map<String, String> headers = {'Content-Type': 'application/json'};

      // Send the JSON data to the ESP32
      await http.post(Uri.parse(url), headers: headers, body: jsonData);
    } catch (e) {
      print('Error sending data to ESP32: $e');
    }
  }


  void _sendpin(int selectedPin,String selectedPinMode){

  }
  void _showOptionsPopupMenu() {
    if (!_isDisconnected) {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
        items: [
          const PopupMenuItem(
            value: 'Radial Gauge',
            child: ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('Radial Gauge'),
            ),
          ),
          const PopupMenuItem(
            value: 'Slider',
            child: ListTile(
              leading: Icon(Icons.linear_scale),
              title: Text('Slider'),
            ),
          ),
          const PopupMenuItem(
            value: 'Display',
            child: ListTile(
              leading: Icon(Icons.text_fields),
              title: Text('Display'),
            ),
          ),
          const PopupMenuItem(
            value: 'Switch',
            child: ListTile(
              leading: Icon(Icons.toggle_on),
              title: Text('Switch'),
            ),
          ),
        ],
      ).then((value) {
        // Handle the selected option
        if (value != null) {
          // Check if the selected type already exists in the list
          bool exists = true;
          if (exists) {
            setState(() {
              _items.add(ItemModel(type: value)); // Add selected option to the list
            });
          } else {
            // Show error message for duplicate selection
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot add duplicate items')),
            );
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add items when disconnected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showOptionsPopupMenu,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Connected To: ${widget.connectedNetwork.ssid}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_items[index].type),
                    onDismissed: (direction) {
                      setState(() {
                        _items.removeAt(index); // Remove item from the list
                      });
                    },
                    background: Container(color: Colors.red),
                    child: buildItem(_items[index],index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildItem(ItemModel item, int index) {
    const double boxHeight = 320; // Increased height of the box
    const double boxWidth = double.infinity; // Width of the box

    return SizedBox(
      height: boxHeight,
      width: boxWidth,
      child: Card(
        elevation: 4,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.title.isNotEmpty ? item.title : item.type,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (item.type == 'Radial Gauge')
                  Expanded(
                    flex: 4, // Adjusted to take up more space
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SfRadialGauge(
                            // Radial Gauge configuration
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: item.minRange,
                                maximum: item.maxRange,
                                ranges: <GaugeRange>[
                                  // Define different ranges with colors
                                  GaugeRange(startValue: item.minRange, endValue: item.maxRange * 0.3, color: Colors.green),
                                  GaugeRange(startValue: item.maxRange * 0.3, endValue: item.maxRange * 0.7, color: Colors.yellow),
                                  GaugeRange(startValue: item.maxRange * 0.7, endValue: item.maxRange, color: Colors.red),
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(value: item.value, enableAnimation: true),
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Text(
                                      item.value.toStringAsFixed(2),
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    angle: 90,
                                    positionFactor: 0.5,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (item.type == 'Slider')
                  Expanded(
                    flex: 1, // Adjusted to take up less space
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Slider(
                            value: _sliderValue,
                            min: item.minRange,
                            max: item.maxRange,
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _sendData(value.toInt().toString());
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Value: ${_sliderValue.toInt()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (item.type == 'Switch')
                  Expanded(
                    child: Center(
                      child: Switch(
                        value: _isSwitchOn,
                        onChanged: (value) {
                          setState(() {
                            _isSwitchOn = value;
                          });
                          // Send data based on switch value
                          int dataToSend = value ? 1 : 0;
                          _sendData(dataToSend.toString());
                        },
                      ),
                    ),
                  ),
                if (item.type == 'Display')
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Handle displaying the value
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Value'),
                            content: Text('${item.value.toInt()}'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${item.value.toInt()}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _showSettingsDialog(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(ItemModel item) {
    TextEditingController titleController = TextEditingController(text: item.title);
    double minRange = item.minRange; // Default minimum range
    double maxRange = item.maxRange; // Default maximum range
    int? selectedPin = item.selectedPin; // Selected pin
    String selectedPinMode = 'Input'; // Default pin mode
    List<String> pinModes = ['Input', 'Output']; 

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Settings'),
        content: Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) {
                    setState(() {
                      item.title = value; // Update the title
                    });
                  },
                ),
                // Add pin mode dropdown
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Pin Mode:'),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedPinMode, // Bind selectedPinMode to the dropdown value
                      onChanged: (String? value) {
                        setState(() {
                          selectedPinMode = value!;
                        });
                      },
                      items: pinModes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // Show only min and max range settings for Radial Gauge
                if (item.type == 'Radial Gauge')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('Minimum Range:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.minRange.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  minRange = double.parse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('Maximum Range:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.maxRange.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  maxRange = double.parse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                // Show min and max range settings for Slider
                if (item.type == 'Slider')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('Minimum Value:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.minRange.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  minRange = double.parse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('Maximum Value:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.maxRange.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  maxRange = double.parse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                // Show pin selection for all widget types
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Select Pin:'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: selectedPin != null ? selectedPin.toString() : '',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              int pin = int.parse(value);
                              // Limit pin range from 1 to 14
                              if (pin < 1) {
                                selectedPin = 1;
                              } else if (pin > 14) {
                                selectedPin = 14;
                              } else {
                                selectedPin = pin;
                              }
                            } else {
                              selectedPin = null;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bool isPinAlreadyAssigned = _items.any((item) => item.selectedPin == selectedPin && item.type != 'Display');
              if (!isPinAlreadyAssigned) {
                setState(() {
                  item.title = titleController.text;
                  if (item.type == 'Radial Gauge') {
                    item.minRange = minRange;
                    item.maxRange = maxRange;
                  }
                  if (item.type == 'Slider') {
                    item.minRange = _minSliderValue;
                    item.maxRange = _maxSliderValue;
                  }
                  item.selectedPin = selectedPin;
                });
                _sendpin(selectedPin ?? 0, selectedPinMode); // Send pin number and mode
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pin already assigned to another item')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ItemModel {
  late String type;
  late String title;
  late double minRange;
  late double maxRange;
  late double value; // Added to hold the value for Display items
  int? selectedPin; // Updated to allow null value

  ItemModel({required this.type, this.title = "", this.minRange = 0, this.maxRange = 100, this.value = 0, this.selectedPin});
}

