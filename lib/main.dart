import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'IDFMData/lines.dart';
import 'IDFMData/trips.dart';
import 'IDFMData/api.dart';
import 'pageStation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
// import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  static var stop_times = [];
  static var lines = [];
  static var trips = [];
  static var stops = [];

  var progressText = "Chargement des données...";

  static Line selectedLine = Line();
  static List<Trip> selectedTrip = [];

  get getStopTimes => stop_times;
  get getLines => lines;
  get getTrips => trips;
  get getStops => stops;

  TextEditingController editingController = TextEditingController();

  List<Widget> column = [
    const SizedBox(
      height: 60,
      child: Center(
        child: Text(
          "Sélectionner une ligne :",
          style: TextStyle(
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        )
      )
    ),
    Container(
      padding: const EdgeInsets.all(10),
      child: const Text(
        "Chargement des données...",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    ),
    const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    ),
  ];

  static final API _api = const API();
  static final Lines _linesData = Lines();
  static final Trips _tripsData = Trips();

  void getDatas(BuildContext context) async {
    await _api.getLines(this).then((value) {
      setState(() {
        lines = value;
      });
    });

    setState(() {
      setProgressText("Traitement des lignes...");
    });
    _linesData.parseLines(lines);
    List<Line> lines_data = _linesData.getLines();

    await _api.getRoutes(this).then((value) {
      setState(() {
        trips = value;
      });
    });

    setState(() {
      setProgressText("Traitement des routes...");
    });
    _tripsData.parseTrips(trips);
    List<Trip> trips_data = _tripsData.getTrips();

    column.add(
      SizedBox(
        height: 500,
        child: ListView.builder(
          itemBuilder: (context, index) {
            var lineName = lines_data[index].route_long_name!;
            var transportType = lines_data[index].getTransportTypeName();
            return ListTile(
              title: Text("$transportType $lineName"),
              //subtitle: Text(tripHeadSign),
              leading: lines_data[index].getLineIcon(1.0),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                selectedLine = lines_data[index];
                selectedTrip = trips_data.where((element) => element.route_id == selectedLine.route_id).toList();
                navigatorKey.currentState!.push(
                  MaterialPageRoute(builder: (context) => PageStations(progressText: progressText)),
                );
                /*SnackBar snackBar = SnackBar(
                  content: Text(lines[index].route_id!),
                  duration: const Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
              },
            );
          },
          itemCount: lines_data.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        )
      )
    );
    /*column.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _linesData.filterSearchResults(value);
            });
          },
          controller: editingController,
          decoration: InputDecoration(
              labelText: "Rechercher une ligne",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              )
            ),
        ),
      ),
    );*/
    setState(() {});

    await _api.getStops(this).then((value) {
      setState(() {
        stops = value;
      });
    });
    await _api.getStopTimes(this).then((value) {
      setState(() {
        stop_times = value;
      });
    });

    removeProgressBar();
    
    // Navigate until that the main page is reached
    if (!context.mounted) return;
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  void setProgressText(String text) {
    progressText = text;
    column[1] = Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    );
    setState(() {});
  }

  void removeProgressBar() {
    column.removeAt(1);
    column.removeAt(1);
    setState(() {
      column = column;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getDatas(context));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Movile',
      home: Builder(builder: (context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 100, 181, 229),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Movile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: "Parisine",
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          )
        ),
        body: Column(
          children: column,
        )
      )),
    );
  }
}
