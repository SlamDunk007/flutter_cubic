import 'package:flutter/material.dart';
import 'package:flutter_cubic/round_pillar_widget.dart';
import 'package:flutter_cubic/toast_widget.dart';

import 'cubic_line_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildCubicWidget(context),
            _buildRoudPillarWidget(context),
            Stack(
              children: <Widget>[
                _buildRoudPillarWidget(context),
                _buildCubicWidget(context)
              ],
            ),
            OutlineButton(onPressed: (){
              Toast.show("普通toast", context);
            }, child: Text("toast"))
          ],
        ));
  }

  Widget _buildCubicWidget(context) {
    return CubicLineWidget(
      cubicBeans: [
        CubicBean(y: 30),
        CubicBean(y: 90),
        CubicBean(y: 60),
        CubicBean(y: 110),
      ],
      size: Size(100, 100),
    );
  }

  Widget _buildRoudPillarWidget(context) {
    return RoundPillarWidget(
        pillarBeans: [
          PillarBean(y: 30, color: Color(0xFFFCDAC1)),
          PillarBean(y: 60, color: Color(0xFFE65724)),
          PillarBean(y: 90, color: Color(0xFFFCDAC1)),
          PillarBean(y: 50, color: Color(0xFFE65724)),
        ],
        size: Size(100, 100),
        rectColor: Colors.deepPurple,
        isReverse: false,
        rectRadiusTopLeft: 20,
        rectRadiusTopRight: 20,
        duration: Duration(milliseconds: 1000));
  }
}
