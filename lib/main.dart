import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'IDFMData/lines.dart';
import 'IDFMData/trips.dart';
import 'IDFMData/traces.dart';
import 'IDFMData/stopTimes.dart';
import 'IDFMData/stops.dart';
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

  static var lines = [];
  static var trips = [];
  static var stops = [];
  static var traces = [];

  static List<StopTime> stop_times_data = [];
  static List<Stop> stops_data = [];

  var progressText = "Chargement des données...";

  static Line selectedLine = Line();
  static List<Trip> selectedTrip = [];
  static Trace selectedTrace = Trace();
  static List<Map<String, List<StopTime>>> selectedStopTimes = [];
  static List<Map<String, List<Stop>>> selectedStops = [];

  get getLines => lines;
  get getTrips => trips;
  get getStops => stops;
  get getTraces => traces;

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

  static API api = API();
  static Lines linesData = Lines();
  static Trips tripsData = Trips();
  static Traces tracesData = Traces();
  static StopTimes stopTimesData = StopTimes();
  static Stops stopsData = Stops();

  void getDatas(BuildContext context) async {
    await api.getLines(this).then((value) {
      setState(() {
        lines = value;
      });
    });
    setState(() {
      setProgressText("Traitement des lignes...");
    });
    linesData.parseLines(lines);
    List<Line> lines_data = linesData.getLines();

    await api.getTraces(this).then((value) {
      setState(() {
        traces = value;
      });
    });
    setState(() {
      setProgressText("Traitement des tracés...");
    });
    tracesData.parseTraces(traces);
    List<Trace> traces_data = tracesData.getTraces();

    await api.getRoutes(this).then((value) {
      setState(() {
        trips = value;
      });
    });
    setState(() {
      setProgressText("Traitement des routes...");
    });
    tripsData.parseTrips(trips);
    List<Trip> trips_data = tripsData.getTrips();

    await api.getStops(this).then((value) {
      setState(() {
        stops = value;
      });
    });
    setState(() {
      setProgressText("Traitement des arrêts...");
    });
    stopsData.parseStops(stops);
    stops_data = stopsData.getStops();

    setState(() {});

    removeProgressBar();

    var bannedTransportSubtitle = ["Subway", "Rail", "Tram"];

    column.add(
      SizedBox(
        height: 500,
        child: Scrollbar(child: ListView.builder(
          itemBuilder: (context, index) {
            var lineName = lines_data[index].route_long_name!;
            var transportType = lines_data[index].getTransportTypeName();
            var traceName = "";
            for (var trace in traces_data) {
              if (trace.route_id == lines_data[index].route_id) {
                if (trace.networkname != null && !bannedTransportSubtitle.contains(trace.route_type!)) {
                  traceName = trace.networkname!;
                } 
              }
            }

            var listTile;

            if (traceName == "") {
              listTile = ListTile(
                title: Text("$transportType $lineName"),
                leading: lines_data[index].getLineIcon(1.0),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  selectedLine = lines_data[index];
                  selectedTrip = trips_data.where((element) => element.route_id == selectedLine.route_id).toList();
                  selectedTrace = traces_data.where((element) => element.route_id == selectedLine.route_id).first;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PageStations(progressText: progressText)),
                  );
                },
              );
            } else {
              listTile = ListTile(
                title: Text("$transportType $lineName"),
                subtitle: Text(
                  traceName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic
                  ),
                ),
                leading: lines_data[index].getLineIcon(1.0),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  selectedLine = lines_data[index];
                  selectedTrip = trips_data.where((element) => element.route_id == selectedLine.route_id).toList();
                  selectedTrace = traces_data.where((element) => element.route_id == selectedLine.route_id).first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageStations(progressText: progressText)),
                  );
                },
              );
            }

            return listTile;
          },
          itemCount: lines_data.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ))
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
