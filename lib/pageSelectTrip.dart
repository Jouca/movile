import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:movile/IDFMData/lines.dart';
import 'package:movile/IDFMData/traces.dart';
import 'package:movile/extensions.dart';
import 'main.dart';
import 'IDFMData/stopTimes.dart';
import 'IDFMData/stops.dart';
import 'IDFMData/trips.dart';
import 'package:marquee/marquee.dart';
import 'pageStation.dart';
import 'pageScreenMetro.dart';
import 'dart:isolate';

class PageSelectTrip extends StatefulWidget {
  PageSelectTrip({super.key});

  var progressText;

  @override
  State<PageSelectTrip> createState() => PageSelectTripState();
}

class PageSelectTripState extends State<PageSelectTrip> {
  static bool isGeographic = true;
  static bool isTime = false;

  static List<List<String>> stop_times_accurate = [];
  static Map<String, List<List<Map<String, List<StopTime>>>>> stationTimes = {};
  static List<List<Map<String, List<StopTime>>>>? stationTimesSelected = [];
  static String stationNameSelected = "";

  List<Color> colors_sncf = ["#004c9f".toColor(), "#001d6e".toColor()];
  List<ListTile?> list = [];

  @override
  void dispose() {
    PageSelectTripState.stationTimes = {};
    PageSelectTripState.stop_times_accurate = [];
    PageSelectTripState.stationTimesSelected = [];
    PageSelectTripState.stationNameSelected = "";
    super.dispose();
  }

  @override
  void initState() {
    PageSelectTripState.stationTimes = {};
    PageSelectTripState.stop_times_accurate = [];
    PageSelectTripState.stationTimesSelected = [];
    PageSelectTripState.stationNameSelected = "";

    loadListView();

    super.initState();
    setState(() {});
  }

  static void getListView(List<Object> objects) {
      Set<String> stationIDs = {};
      List<List<String>> tempList = [];

      SendPort sendPort = objects[0] as SendPort;
      List<Map<Stop, List<Map<String, String>>>> stopsSelected = objects[1] as List<Map<Stop, List<Map<String, String>>>>;
      List<Trip> tripsSelected = objects[2] as List<Trip>;
      List<Map<String, List<StopTime>>> stopsTimes = objects[3] as List<Map<String, List<StopTime>>>;
      List<Stop> stopsData = objects[4] as List<Stop>;

      for (var stop in stopsSelected) {
        stationIDs.add(stop.keys.first.stop_id!);
      }

      for (var trips in tripsSelected) {
        try {
          var stop_times = stopsTimes.where((element) => element.keys.first == trips.trip_id).toList();
        
          // fetch station first
          var stationLast = stop_times.lastWhere((element) => element.keys.first == trips.trip_id).values.first;
          if (stationIDs.contains(stationLast.first.stop_id)) continue;

          var stations = stop_times.where((element) => element.keys.first == trips.trip_id).toList();
          var stationsTemp = List<Map<String, List<StopTime>>>.from(stations);
          for (var station in stationsTemp) {
            var stationID = station.values.first.first.stop_id;
            if (!stationIDs.contains(stationID)) {
              stations.remove(station);
            } else {
              break;
            }
          }
          if (stations.isEmpty) continue;

          var stationLastName = stopsData.firstWhere((element) => element.stop_id == stationLast.first.stop_id);
          if (stationTimes.containsKey(stationLastName.stop_name)) {
            stationTimes[stationLastName.stop_name!]?.add(stations);
          } else {
            stationTimes[stationLastName.stop_name!] = [stations];

            var stationsListString = "";
            for (var station in stations) {
              if (station.values.first.first.stop_id == stationLast.first.stop_id) continue;
              stationsListString += "${stopsData.firstWhere((element) => element.stop_id == station.values.first.first.stop_id).stop_name} > ";
            }
            stationsListString += "${stopsData.firstWhere((element) => element.stop_id == stationLast.first.stop_id).stop_name}";

            tempList.add([stationLastName.stop_name!, stationsListString]);
          }
        } catch (e) {
          continue;
        }
      }

      if (tempList.isNotEmpty) {
        sendPort.send([tempList, stationTimes]);
      } else {
        sendPort.send([[null], null]);
      }
  }

  void loadListView() {
    // Create a ReceivePort to receive messages from the isolate.
    ReceivePort receivePort = ReceivePort();

    // Create a new isolate and pass the send port of the receive port to it.
    Isolate.spawn(getListView, [
      receivePort.sendPort,
      PageStationsState.stopsSelected,
      MyAppState.selectedTrip,
      MyAppState.selectedStopTimes,
      MyAppState.stops_data
    ]);

    // Listen for the message from the isolate.
    receivePort.listen((data) {
      List<List<String>> stationsString = data[0];
      Map<String, List<List<Map<String, List<StopTime>>>>> stationTimes = data[1];

      var index = 0;
      for (var station in stationsString) {
        if (station == null) {
          list.add(null);
          continue;
        }
        list.add(
          ListTile(
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            title: Text(
              "${station[0]}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Parisine",
                color: Colors.white
              )
            ),
            subtitle: SizedBox(
              width: 200,
              height: 20,
              child: Marquee(
                text: station[1],
                style: const TextStyle(
                  color: Colors.white
                ),
                scrollAxis: Axis.horizontal,
                blankSpace: 400,
                accelerationDuration: Duration(seconds: 1),
                accelerationCurve: Curves.linear,
              )
            ),
            tileColor: colors_sncf[list.length % 2],
            onTap: () {
              PageSelectTripState.stationTimesSelected = stationTimes[station[0]];
              PageSelectTripState.stationNameSelected = station[0]; 
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PageScreenMetro()));
            },
          )
        );
      }
      try {
        setState(() {});
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var lineName = MyAppState.selectedLine.route_long_name;
    var transportType = MyAppState.selectedLine.getTransportTypeName();
    var stationName = PageStationsState.stopSelected.first.keys.first.stop_name;

    var transportLogo = Container(
      padding: const EdgeInsets.all(10),
      child: Center(child: MyAppState.selectedLine.getLineIcon(3.0)),
    );
    var lineLogo = Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: AutoSizeText(
        "$transportType $lineName",
        maxFontSize: 40,
        minFontSize: 20,
        textAlign: TextAlign.center,
      )
    );
    var stationNameContainer = Container(
      padding: const EdgeInsets.all(10),
      color: const Color.fromRGBO(5, 13, 158, 1),
      child: AutoSizeText(
        "$stationName",
        maxFontSize: 40,
        minFontSize: 25,
        textAlign: TextAlign.center,
        wrapWords: false,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Parisine",
          color: Colors.white
        ),
      )
    );

    List<Widget> column = [
      const Center(
        child: Text(
          "Sélectionner le mode de changement de station :",
          style: TextStyle(
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        )
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: isGeographic,
            onChanged: (bool value) {
              setState(() {
                isGeographic = value;
                isTime = false;
              });
            }
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: const Text(
              "Position géographique",
              style: TextStyle(
                fontSize: 20,
              )
            )
          )
        ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: isTime,
            onChanged: (bool value) {
              setState(() {
                isTime = value;
                isGeographic = false;
              });
            }
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: const Text(
              "Basé sur le temps (GTFS)",
              style: TextStyle(
                fontSize: 20,
              )
            )
          )
        ]
      ),
      const Center(
        child: Text(
          "Sélectionner la direction :",
          style: TextStyle(
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        )
      ),
      const CircularProgressIndicator(),
    ];

    if (list.isNotEmpty) {
      column.removeLast();
      column.add(
        Card(child:SizedBox(
          height: 200,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return list[index];
            },
            itemCount: list.length,
            shrinkWrap: true,
          )
        ))
      );
    }

    return PopScope(
      canPop: MyAppState.canPop,
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
          body: 
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      transportLogo,
                      lineLogo,
                      stationNameContainer
                    ],
                  )
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: column
                  )
                )
              ]
            )
        )
      ),
      onPopInvoked: (didPop) {
        if (didPop) {
          PageSelectTripState.stop_times_accurate = [];
          PageSelectTripState.stationTimes = {};
          PageSelectTripState.stationTimesSelected = [];
          PageSelectTripState.stationNameSelected = "";

          PageStationsState.stopSelected = [];
          PageStationsState.stopsSelected = [];

          MyAppState.selectedLine = Line();
          MyAppState.selectedTrip = [];
          MyAppState.selectedTrace = Trace();
          MyAppState.selectedStopTimes = [];
          MyAppState.selectedStops = [];

          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ]);
        }
      },
    );
  }
}