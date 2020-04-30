import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  Color selectedColor;
  double strokeWidth;

  @override
  void initState() {
    //  implement initState
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  chooseColor() {
// ValueChanged<Color> callback
    void changeColor(Color color) {
      setState(() => selectedColor = color);
    }

    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(138, 35, 135, 1.0),
                    Color.fromRGBO(233, 64, 87, 1.0),
                    Color.fromRGBO(242, 113, 33, 1.0),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    //alignment: Alignment.bottomRight,
                    width: width * 0.8,
                    height: height * 0.75,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        )
                      ],
                    ),
                    child: GestureDetector(
                      onPanDown: (update) {
                        setState(() {
                          points.add(
                            DrawingArea(
                              point: update.localPosition,
                              areaPaint: Paint()
                                ..color = selectedColor
                                ..strokeWidth = strokeWidth
                                ..strokeCap = StrokeCap.round,
                            ),
                          );
                        });
                      },
                      onPanEnd: (update) {
                        setState(() {
                          points.add(null);
                        });
                      },
                      onPanUpdate: (update) {
                        setState(() {
                          points.add(
                            DrawingArea(
                              point: update.localPosition,
                              areaPaint: Paint()
                                ..color = selectedColor
                                ..strokeWidth = strokeWidth
                                ..strokeCap = StrokeCap.round,
                            ),
                          );
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: CustomPaint(
                          painter: MyCustomPainter(
                            points: points,
                            selectedColor: selectedColor,
                            strokeWidth: strokeWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    width: width * 0.80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.color_lens,
                            //color: selectedColor,
                          ),
                          onPressed: () {
                            chooseColor();
                          },
                          color: selectedColor,
                        ),
                        Expanded(
                          child: Slider(
                              min: 1.0,
                              max: 7.0,
                              activeColor: selectedColor,
                              value: strokeWidth,
                              onChanged: (value) {
                                setState(() {
                                  strokeWidth = value;
                                });
                              }),
                        ),
                        IconButton(
                            icon: Icon(Icons.layers_clear),
                            onPressed: () {
                              setState(() {
                                points.clear();
                              });
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;
  Color selectedColor;
  double strokeWidth;
  MyCustomPainter({this.points, this.selectedColor, this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    //  implement paint
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
//    RRect rect = RRect.fromLTRBAndCorners(
//      0,
//      0,
//      size.width,
//      size.height,
//      topLeft: Radius.circular(20.0),
//      topRight: Radius.circular(20.0),
//      bottomRight: Radius.circular(20.0),
//      bottomLeft: Radius.circular(20.0),
//    );
    canvas.drawRect(rect, background);
    //canvas.drawRRect(rect, background);
    // Paint paint = Paint();
    // paint.color = selectedColor;
    // paint.strokeWidth = strokeWidth;
    // paint.strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(points[i].point, points[i + 1].point, points[i].areaPaint);
      else if (points[i] != null && points[i + 1] == null)
        canvas.drawPoints(PointMode.points, [points[i].point], points[i].areaPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //  implement shouldRepaint
    return true;
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint
  });
}
