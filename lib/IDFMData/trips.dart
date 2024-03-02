import 'package:flutter/material.dart';
import 'package:movile/extensions.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Trip {
  String? route_id;
  String? service_id;
  String? trip_id;
  String? trip_headsign;
  String? trip_short_name;
  String? direction_id;
  String? block_id;
  String? shape_id;
  String? wheelchair_accessible;
  String? bikes_allowed;

  Trip({
    this.route_id,
    this.service_id,
    this.trip_id,
    this.trip_headsign,
    this.trip_short_name,
    this.direction_id,
    this.block_id,
    this.shape_id,
    this.wheelchair_accessible,
    this.bikes_allowed,
  });
}

class Trips {
  List<Trip> trips = [];

  List<Trip> getTrips() {
    return trips;
  }

  void parseTrips(List<dynamic> data) {
    for (var i = 1; i < data.length; i++) {
      var trip = Trip(
        route_id: data[i][0].toString(),
        service_id: data[i][1].toString(),
        trip_id: data[i][2].toString(),
        trip_headsign: data[i][3].toString(),
        trip_short_name: data[i][4].toString(),
        direction_id: data[i][5].toString(),
        block_id: data[i][6].toString(),
        shape_id: data[i][7].toString(),
        wheelchair_accessible: data[i][8].toString(),
        bikes_allowed: data[i][9].toString(),
      );
      trips.add(trip);
    }
  }
}