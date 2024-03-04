import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:isolate';
import 'traces.dart';
import 'package:csv/csv.dart';
import 'package:movile/main.dart';
import 'package:http/http.dart' as http;

class API {
  const API();

  Future<List<List<dynamic>>> getLines(MyAppState myapp) async {
    try {
      myapp.setProgressText("Chargement des lignes...");
      var byteData1 = await rootBundle.load('assets/data/routes.csv');
      List<int> bytes1 = byteData1.buffer.asUint8List(byteData1.offsetInBytes, byteData1.lengthInBytes);
      List<List<dynamic>> data_lines = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes1)));
      print("Data Lines : ${data_lines.length}");

      return data_lines;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  Future<List<List<dynamic>>> getStops(MyAppState myapp) async {
    try {
      myapp.setProgressText("Chargement des arrêts...");
      var byteData1 = await rootBundle.load('assets/data/stops.csv');
      List<int> bytes1 = byteData1.buffer.asUint8List(byteData1.offsetInBytes, byteData1.lengthInBytes);
      List<List<dynamic>> data_stops = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes1)));
      print("Data Stops : ${data_stops.length}");

      return data_stops;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  Future<List<List<dynamic>>> getRoutes(MyAppState myapp) async {
    try {
      myapp.setProgressText("Chargement des routes...");
      var byteData1 = await rootBundle.load('assets/data/trips.csv');
      List<int> bytes1 = byteData1.buffer.asUint8List(byteData1.offsetInBytes, byteData1.lengthInBytes);
      List<List<dynamic>> data_routes = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes1)));
      print("Data Routes : ${data_routes.length}");

      return data_routes;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  Future<List<dynamic>> getTraces(MyAppState myapp) async {
    try {
      myapp.setProgressText("Chargement des traces...");
      var string = await rootBundle.loadString('assets/data/traces-des-lignes-de-transport-en-commun-idfm.json');
      List<dynamic> data_traces = await Isolate.run(() => jsonDecode(string) as List<dynamic>);
      print("Data Traces : ${data_traces.length}");

      return data_traces;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  Future<List<dynamic>> getStopTimes() async {
    try {
      String trips = "";
      for (var trip in MyAppState.selectedTrip) {
        trips += "${trip.trip_id},";
      }
      trips = trips.substring(0, trips.length - 1);

      var url = Uri.https("clarifygdps.com", "/idfm_api/getStopTimes.php");
      var response = await http.post(url, body: {"trip_id": trips});
      if (response.statusCode != 200) {
        return [];
      }

      var byteData = response.body;
      List<dynamic> data_stoptime = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(byteData));
      data_stoptime.removeAt(0);
      print("Data StopTimes : ${data_stoptime.length}");

      return data_stoptime;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }
}