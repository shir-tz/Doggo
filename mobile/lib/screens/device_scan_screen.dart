import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/services/ble_service.dart';
import 'battery_level_screen.dart';

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  _DeviceScanScreenState createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  String? deviceId;
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();

    final scanCompleter = BleService().startScan((id) {
      setState(() {
        deviceId = id;
      });
    });

    Future.any(
        <Future>[scanCompleter.future, Future.delayed(const Duration(seconds: 30))])
        .then((_) {
      if (deviceId == null) {
        setState(() {
          deviceId = 'not_found';
        });
      } else {
        BleService bleService = BleService();
        bleService.connectToDevice(deviceId!, (level) {
          Navigator.push(
            context,
            MaterialPageRoute(
              //builder: (context) => BatteryLevelScreen(batteryLevel: level),
              builder: (context) => BatteryLevelScreen(deviceId: deviceId!, bleService: bleService)
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning for Devices'),
      ),
      body: Center(
        child: deviceId == 'not_found'
            ? const Text('DoggoCollar not found :(\nPlease try again.')
            : (deviceId == null
            ? const Text('Scanning for DoggoCollar...')
            : const Text('Connecting to DoggoCollar...')),
      ),
    );
  }
}