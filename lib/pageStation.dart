import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'main.dart';

class PageStations extends StatefulWidget {
  PageStations({super.key, required this.progressText});

  var progressText;

  @override
  State<PageStations> createState() => _PageStationsState();
}

class _PageStationsState extends State<PageStations> {
  var stop_times = MyAppState.stop_times;
  var lines = MyAppState.lines;
  var trips = MyAppState.trips;
  var stops = MyAppState.stops;

  @override
  Widget build(BuildContext context) {
    var lineName = MyAppState.selectedLine.route_long_name;
    var transportType = MyAppState.selectedLine.getTransportTypeName();

    List<Widget> column = [
      Container(
        padding: const EdgeInsets.all(10),
        child: Center(child: MyAppState.selectedLine.getLineIcon(3.0)),
      ), 
      Container(
        padding: const EdgeInsets.only(bottom: 50),
        child: AutoSizeText(
          "$transportType $lineName",
          maxFontSize: 40,
          minFontSize: 20,
          textAlign: TextAlign.center,
        )
      )
    ];

    if (stop_times.isNotEmpty) {
      
    } else {
      column.add(
        Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              Text(
                widget.progressText,
                style: const TextStyle(
                  fontSize: 20,
                ),
              )
            ]
          )
        )
      );
    }

    return MaterialApp(
      title: 'Movile',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 100, 181, 229),
          title: const Column(
            children: [
              Center(child: Text(
                'Movile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: "Parisine",
                  fontWeight: FontWeight.bold
                ),
              ))
            ],
          )
        ),
        body: Column(
          children: column,
        )
      )
    );
  }
}