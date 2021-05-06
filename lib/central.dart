import 'dart:convert';

import 'package:flutter_ble_joystick_test/central_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Central extends StatelessWidget {
  Central({Key? key, required this.title}): super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CentralModel>(
      create: (_) => CentralModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Consumer<CentralModel>(builder: (context, model, child) {
          return Stack (
            children: [
              _background(),
              CustomPaint(
                child: Container(),
                painter: MyPainter(this.parseOffset(model.receiveString))
              ),
              SafeArea(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Central Model'
                  ),
                  Text(
                    '${model.receiveString}',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 30, width: double.infinity,),
                  RaisedButton(
                    onPressed: () {
                      if (model.isConnected() == true) {
                        model.disconnect();
                      } else {
                        model.scanDevices();
                      }
                    },
                    child: Text(
                      (model.isConnected() == true ? 'Disconnect' : 'Connect'),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          model.writeString('send message test');
                        },
                        child: const Text('test', style: TextStyle(fontSize: 20)),
                      )
                    ],
                  )
                ],
              ))
            ],
          );
        }),
      ),
    );
  }

  Widget _background() {
    return Consumer<CentralModel>(builder: (context, model, child) {
      return Container(
        color: Colors.white,
      );
    });
  }

  List<Offset> parseOffset(String receiveString) {
    try {
      Map<String, dynamic> val = json.decode(receiveString);
      Offset offset = Offset(val["x"].toDouble(), val["y"].toDouble());
      List<Offset> offsetList = [offset];
      return offsetList;
    } catch (e) {
      print(e);
      print(receiveString);
      return [];
    }
  }
}

class MyPainter extends CustomPainter{
  final List<Offset> _points;
  final _dotPaint = Paint()..color = Colors.black;

  MyPainter(this._points);

  @override
  void paint(Canvas canvas, Size size) {
    _points.forEach((offset) {
      Offset offsetByCenter = new Offset(size.width/2 - (offset.dx - 127), size.height/2 + (offset.dy - 127));
      canvas.drawCircle(offsetByCenter, 10.0, _dotPaint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}