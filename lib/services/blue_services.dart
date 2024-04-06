import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:developer' as dev;

import '../permission/bluetooth_permission.dart';
import '../permission/location_permission.dart';

class BlueServices {
  bool status = false;
  String blueID = '';

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>.empty(growable: true);


  Future<void> startDiscovery() async {
    dev.log('started Discovery');
    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final existingIndex = results.indexWhere((element) => element.device.address == r.device.address);
      if (existingIndex >= 0) {
        results[existingIndex] = r;
      } else {
        results.add(r);
      }
    });
    _streamSubscription!.onDone(() {
      dev.log('results - ${results[0].device.name.toString()}');
      dev.log('results - ${results[0].device.address.toString()}');
      print('results - ${results[0].device.address.toString()}');
      for(BluetoothDiscoveryResult blue in results){
        Fluttertoast.showToast(
            msg: "blue id"+blue.device.address,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }


    });

  }

  void cancelDiscovery() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }






  Future<bool> turnOn() async {
    getState();
    if (_bluetoothState.isEnabled) {
      dev.log('Bluetooth already enabled');

    } else {
      dev.log('requesting to turn on');
      await FlutterBluetoothSerial.instance.requestEnable();
      dev.log('enabled');
    }
    return _bluetoothState.isEnabled;
  }

  void getState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
    });
    dev.log(_bluetoothState.toString());
  }

  bool validateID(blueID) {
    int len = blueID.length;
    bool validID = false;

    if (len == 17) {
      final splitted = blueID.split(":");
      var listLength = splitted.length;

      if (listLength == 6) {
        for (var i = 0; i < listLength; i++) {
          if (splitted[i].length != 2) {
            validID = false;
            dev.log('Invalid');
            return validID;
          }
        }
        validID = true;
        dev.log('Valid ');
        return validID;
      } else {
        validID = false;
        dev.log('Invalid ');
        return validID;
      }
    } else {
      validID = false;
      dev.log('Invalid ');
      return validID;
    }
  }

  Future<void> sendDataOverBluetooth(BluetoothConnection connection, String dataToSend) async {
    try {
      connection.output.add(utf8.encode(dataToSend + '\r\n'));
      await connection.output.allSent;
      Fluttertoast.showToast(
          msg: 'Data sent over Bluetooth: $dataToSend',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      dev.log('Error sending data over Bluetooth: $e');
      Fluttertoast.showToast(
          msg: 'Error sending data over Bluetooth',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }



  Future triggerPipelinetoDiscover(testName) async {

    try {
      final locationStatus = await checkLocationPermissions();
      if (!locationStatus){
        return status;

      }
      final blueStatus = await checkBluetoothPermissions();
      if (!blueStatus){
        return status;
      }

      final blueON = await turnOn();
      if (!blueON) {
        return status;
      }

      // help to get blue address and name
      startDiscovery();


    } catch (e){
      dev.log(e.toString());
      return status;
    }

  }






  //single device



  BluetoothConnection? _connection;

  Future<void> connectToDevice(String address) async {
    try {
      bool isAlreadyPaired = await _isDevicePaired(address);
      if (!isAlreadyPaired) {
        bool isPairSuccess = await _pairDevice(address);
        if (!isPairSuccess) {
          Fluttertoast.showToast(
            msg: 'Failed to pair with the device',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
      }

      // Now attempt to connect
      _connection = await BluetoothConnection.toAddress(address);
      Fluttertoast.showToast(
        msg: 'Connected to IoT device!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error connecting to IoT device: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<bool> _isDevicePaired(String address) async {
    List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    return pairedDevices.any((device) => device.address == address);
  }

  Future<bool> _pairDevice(String address) async {
    try {
      bool? isPairSuccess = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(address);
      if (!isPairSuccess!) {
        Fluttertoast.showToast(
          msg: 'Failed to pair with the device',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return isPairSuccess;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error pairing with the device: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<void> sendDataOverSingleBluetooth(String dataToSend) async {
    try {
      _connection?.output.add(utf8.encode(dataToSend + '\r\n'));
      await _connection?.output.allSent;
      Fluttertoast.showToast(
        msg: 'Data sent over Bluetooth: $dataToSend',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error sending data over Bluetooth: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> triggerPipelineToConnect(String blueAddress) async {
    try {
      bool isBluetoothEnabled = await turnOnBluetooth();
      if (!isBluetoothEnabled) {
        return;
      }

      await connectToDevice(blueAddress);

      await sendDataOverSingleBluetooth("Hello from bluetooth");

    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error triggering pipeline: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<bool> turnOnBluetooth() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState.isEnabled) {
      return true;
    } else {
      try {
        await FlutterBluetoothSerial.instance.requestEnable();
        _bluetoothState = await FlutterBluetoothSerial.instance.state;
        return _bluetoothState.isEnabled;
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error turning on Bluetooth: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    }
  }
}
