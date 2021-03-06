import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class CentralModel extends ChangeNotifier {

  final _connectToLocalName = "M5Stick-Joy-PoC";
  final _timeout = 4;
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  String receiveString = 'none';
  Offset offset = new Offset(127.0, 127.0);
  bool isClicked = false;
  List<int> receiveRow = [];

  void scanDevices() {
    _flutterBlue.startScan(timeout: Duration(seconds: _timeout));
    // ignore: cancel_subscriptions
    var subscription = _flutterBlue.scanResults.listen((results) async {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name == _connectToLocalName) {
          if (_device == null) {
            _device = r.device;
            notifyListeners();
            await connect();
            break;
          }
        }
      }
    });
    _flutterBlue.stopScan();
  }

  Future<void> connect() async {
    await _device!.connect();
    print('connect');

    List<BluetoothService> services = await _device!.discoverServices();
    services.forEach((service) async {
      service.characteristics.forEach((characteristic) async {
        if (characteristic.properties.write) {
          _writeCharacteristic = characteristic;
          print('write');
        } else if (characteristic.properties.notify) {
          _notifyCharacteristic = characteristic;
          await _notifyCharacteristic!.setNotifyValue(true);
          _notifyCharacteristic!.value.listen((value) {
            receiveRow = value;
            receiveString = utf8.decode(value);
            this.getOffset(receiveString);
            print('received:$receiveString');
            notifyListeners();
          });
          print('notify');
        }
      });
    });
  }
  void disconnect() {
    _device!.disconnect();
    _device = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    print('disconnect');
    notifyListeners();
  }

  void write(List<int> message) {
    if (_writeCharacteristic != null) {
      _writeCharacteristic!.write(message);
    }
  }

  void writeString(String message) {
    if (_writeCharacteristic != null) {
      _writeCharacteristic!.write(utf8.encode(message));
    }
  }

  bool isConnected() {
    if (_device == null) {
      return false;
    }
    return true;
  }

  void getOffset(String receiveString) {
    try {
      Map<String, dynamic> val = json.decode(receiveString);
      Offset offset = Offset(val["x"].toDouble(), val["y"].toDouble());
      this.offset = offset;
      this.isClicked = val["button"]==1;
    } catch (e) {
      print(e);
      //print(receiveString);
    }
  }
}