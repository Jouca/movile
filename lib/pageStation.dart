import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'IDFMData/stops.dart';
import 'IDFMData/stopTimes.dart';
import 'IDFMData/lines.dart';
import 'IDFMData/traces.dart';
import 'extensions.dart';
import 'main.dart';

import 'pageSelectTrip.dart';

class PageStations extends StatefulWidget {
  PageStations({super.key, required this.progressText});

  var progressText;

  @override
  State<PageStations> createState() => _PageStationsState();
}

class _PageStationsState extends State<PageStations> {
  var stop_times = MyAppState.stop_times_data;
  var lines = MyAppState.lines;
  var trips = MyAppState.trips;
  List<Stop> stops = [];
  List<Marker> markers = [];

  static Map<Stop, List<String>> stopSelected = {};

  @override
  void dispose() {
    MyAppState.selectedLine = Line();
    MyAppState.selectedTrip = [];
    MyAppState.selectedTrace = Trace();
    MyAppState.selectedStopTimes = [];
    MyAppState.selectedStops = [];
    _PageStationsState.stopSelected = {};
    stops = [];
    markers = [];

    super.dispose();
  }

  @override
  void initState() { 
    MyAppState.selectedStopTimes = [];
    MyAppState.stopTimesData = StopTimes();
    downloadStopTimes();

    super.initState();
    setState(() {});
  }

  void downloadStopTimes() async {
    List<dynamic> stop_times = [];
    await MyAppState.api.getStopTimes().then((value) {
      setState(() {
        stop_times = value;
      });
      widget.progressText = "Traitement des missions...";
      MyAppState.stopTimesData.parseStopTimes(stop_times);
      MyAppState.selectedStopTimes = MyAppState.stopTimesData.getStopTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    var lineName = MyAppState.selectedLine.route_long_name;
    var transportType = MyAppState.selectedLine.getTransportTypeName();

    List<Polyline> polylines = [];
    if (MyAppState.selectedTrace.shape != null) {
      for (List<List<double>> shape in MyAppState.selectedTrace.shape!.coordinates!) {
        polylines.add(
          Polyline(
            points: shape.unpackPolyline(),
            color: MyAppState.selectedLine.route_color!.toColor(),
            strokeWidth: 5.0
          )
        );
      }
    }

    List<LatLng> points = [];
    for (var polyline in polylines) {
      points.addAll(polyline.points);
    }
    final bounds = LatLngBounds.fromPoints(points);
    MapController mapController = MapController();

    FlutterMap flutterMap = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(10)),
        keepAlive: true
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.example.movile",
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
            ),
          ],
        ),
        PolylineLayer(
          polylines: polylines,
          polylineCulling: true,
        ),
        MarkerLayer(markers: markers)
      ],
    );

    List<Widget> column = [
      Container(
        padding: const EdgeInsets.all(10),
        child: Center(child: MyAppState.selectedLine.getLineIcon(3.0)),
      ), 
      Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: AutoSizeText(
          "$transportType $lineName",
          maxFontSize: 40,
          minFontSize: 20,
          textAlign: TextAlign.center,
        )
      ),
      SizedBox(
        height: 250,
        child: flutterMap
      ),
    ];
    
    if (MyAppState.selectedStopTimes.isNotEmpty) {
      List<String> stopIDs = [];
      List<String> stopTrips = [];
      // Make selectedStopTimes distinct by stop_id
      for (var stopTime in MyAppState.selectedStopTimes) {
        for (var stop in stopTime.keys) {
          if (!stopIDs.contains(stopTime[stop]!.first.stop_id!)) {
            stopIDs.add(stopTime[stop]!.first.stop_id!);
            stopTrips.add(stopTime[stop]!.first.trip_id!);
          }
        }
      }

      List<Stop> stops = [];
      for (var stopID in stopIDs) {
        // check if stop_id from stop_datas is in stopIDs
        if (MyAppState.stops_data.any((element) => element.stop_id == stopID)) {
          stops.add(MyAppState.stops_data.firstWhere((element) => element.stop_id == stopID));
        }
      }

      // sort stops by stop_name
      stops.sort((a, b) => a.stop_name!.compareTo(b.stop_name!));

      List<Map<Stop, List<String>>> stopWithIDs = [];
      for (var stop in stops) {
        List<String> stopIDsTemp = [];
        for (var stopTrip in stopTrips) {
          if (MyAppState.selectedTrip.any((element) => element.trip_id == stopTrip)) {
            stopIDsTemp.add(stopTrip);
          }
        }
        stopWithIDs.add({stop: stopIDsTemp});
      }

      // Remove repeated stops
      var stopWithIDsTemp = List<Map<Stop, List<String>>>.from(stopWithIDs);
      for (var stop in stopWithIDsTemp) {
        // count if stop_name is repeated
        if (stopWithIDs.where((element) => element.keys.first.stop_name == stop.keys.first.stop_name).length > 1) {
          // Remove just the first occurrence
          stopWithIDs.remove(stop);
        }
      }

      column.add(
        SizedBox(
          height: 250,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: AutoSizeText(
                  stopWithIDs[index].keys.first.stop_name!,
                  maxFontSize: 20,
                  minFontSize: 10,
                  textAlign: TextAlign.left,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                leading: RotatedBox(quarterTurns: 1, child: Icon(Icons.commit, color: MyAppState.selectedLine.route_color!.toColor(), size: 40)),
                onTap: () {
                  _PageStationsState.stopSelected = stopWithIDs[index];
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PageSelectTrip())
                  );
                }
              );
            },
            itemCount: stopWithIDs.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )
        )
      );
      setState(() {});
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

    return PopScope(
      canPop: false,
      child: MaterialApp(
        title: 'Movile',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 100, 181, 229),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const Center(child: Text(
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
      )
    );
  }
}