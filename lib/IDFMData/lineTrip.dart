import 'stopTimes.dart';
import 'dart:core';
import '../main.dart';

class LineTrip {
  var route_ID;
  var trip_ID;
  var trip_headsign;
  var route_type;
  List<DateTime>? departure_times;
  List<StopTime>? stations;
  List<List<double>>? coordinates = [];

  LineTrip(
    {
      this.route_ID,
      this.trip_ID,
      this.trip_headsign,
      this.departure_times,
      this.stations,
      this.route_type,
    }
  );

  List<StopTime> getStations() {
    return this.stations!;
  }

  List<List<double>> getCoordinates() {
    return this.coordinates!;
  }

  void addCoordinates(String stop_id) {
    for (int i = 0; i < this.stations!.length; i++) {
      if (this.stations![i].stop_id == stop_id) {
        this.coordinates!.add([
          double.parse(MyAppState.stops_data.firstWhere((element) => element.stop_id == stop_id).stop_lon!),
          double.parse(MyAppState.stops_data.firstWhere((element) => element.stop_id == stop_id).stop_lat!)
        ]);
        break;
      }
    }
  }

  List<DateTime> getDepartureTimes() {
    return this.departure_times!;
  }

  int update(String stop_id) {
    // Remove until it's not the stop_id
    int count = 0;
    for (int i = 0; i < this.stations!.length; i++) {
      if (this.stations![0].stop_id != stop_id) {
        this.stations!.removeAt(0);
        this.coordinates!.removeAt(0);
        this.departure_times!.removeAt(0);
      } else {
        break;
      }
      count++;
    }
    try {
      this.stations!.removeAt(0);
      this.coordinates!.removeAt(0);
      this.departure_times!.removeAt(0);
      return count;
    } catch (e) {
      return -1;
    }
  }

  int updateDateTime(DateTime dateTime) {
    int count = 0;
    for (int i = 0; i < this.departure_times!.length; i++) {
      if (this.departure_times![0].isBefore(dateTime)) {
        this.stations!.removeAt(0);
        this.coordinates!.removeAt(0);
        this.departure_times!.removeAt(0);
      } else {
        break;
      }
      count++;
    }
    return count;
  }

  String getTransportTypeName() {
    switch (route_type) {
      case "0":
        return "Tramway";
      case "1":
        return "Métro";
      case "2":
        switch(route_ID) {
          case "IDFM:C01742":
            return "RER";
          case "IDFM:C01743":
            return "RER";
          case "IDFM:C01727":
            return "RER";
          case "IDFM:C01728":
            return "RER";
          case "IDFM:C01729":
            return "RER";
          case "IDFM:C01737":
            return "Transilien";
          case "IDFM:C01739":
            return "Transilien";
          case "IDFM:C01738":
            return "Transilien";
          case "IDFM:C01740":
            return "Transilien";
          case "IDFM:C01736":
            return "Transilien";
          case "IDFM:C01730":
            return "Transilien";
          case "IDFM:C01731":
            return "Transilien";
          case "IDFM:C01741":
            return "Transilien";
          default:
            return "Train";
        }
      case "3":
        return "Bus";
      default:
        return "Bus";
    }
  }
}