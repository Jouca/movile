import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:isolate';
import 'package:csv/csv.dart';
import 'package:movile/main.dart';

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

  Future<List<List<dynamic>>> getStopTimes(MyAppState myapp) async {
    try {
      myapp.setProgressText("Chargement des missions (1/5)...");
      var byteData1 = await rootBundle.load('assets/data/stop_times_1.csv');
      List<int> bytes1 = byteData1.buffer.asUint8List(byteData1.offsetInBytes, byteData1.lengthInBytes);
      List<List<dynamic>> data_stoptime1 = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes1)));
      print("Data Stop Time 1 : ${data_stoptime1.length}");

      myapp.setProgressText("Chargement des missions (2/5)...");
      var byteData2 = await rootBundle.load('assets/data/stop_times_2.csv');
      List<int> bytes2 = byteData2.buffer.asUint8List(byteData2.offsetInBytes, byteData2.lengthInBytes);
      List<List<dynamic>> data_stoptime2 = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes2)));
      print("Data Stop Time 2 : ${data_stoptime2.length}");

      myapp.setProgressText("Chargement des missions (3/5)...");
      var byteData3 = await rootBundle.load('assets/data/stop_times_3.csv');
      List<int> bytes3 = byteData3.buffer.asUint8List(byteData3.offsetInBytes, byteData3.lengthInBytes);
      List<List<dynamic>> data_stoptime3 = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes3)));
      print("Data Stop Time 3 : ${data_stoptime3.length}");

      myapp.setProgressText("Chargement des missions (4/5)...");
      var byteData4 = await rootBundle.load('assets/data/stop_times_4.csv');
      List<int> bytes4 = byteData4.buffer.asUint8List(byteData4.offsetInBytes, byteData4.lengthInBytes);
      List<List<dynamic>> data_stoptime4 = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes4)));
      print("Data Stop Time 4 : ${data_stoptime4.length}");

      myapp.setProgressText("Chargement des missions (5/5)...");
      var byteData5 = await rootBundle.load('assets/data/stop_times_5.csv');
      List<int> bytes5 = byteData5.buffer.asUint8List(byteData5.offsetInBytes, byteData5.lengthInBytes);
      List<List<dynamic>> data_stoptime5 = await Isolate.run(() => const CsvToListConverter(shouldParseNumbers: false, convertEmptyTo: EmptyValue.NULL, eol: "\n").convert(utf8.decode(bytes5)));
      print("Data Stop Time 5 : ${data_stoptime5.length}");

      List<List<dynamic>> data = [];
      data.addAll(data_stoptime1);
      data.addAll(data_stoptime2);
      data.addAll(data_stoptime3);
      data.addAll(data_stoptime4);
      data.addAll(data_stoptime5);

      return data;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }
}