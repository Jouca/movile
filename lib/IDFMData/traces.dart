import 'dart:convert';

class RecordTrace {
  final String? datasetid;
  final String? recordid;
  final Trace? fields;
  final Geometry? geometry;
  final String? record_timestamp;

  RecordTrace({this.datasetid, this.recordid, this.fields, this.geometry, this.record_timestamp});

  factory RecordTrace.fromJson(Map<String, dynamic> json) {
    return RecordTrace(
      datasetid: json['datasetid'],
      recordid: json['recordid'],
      fields: Trace.fromJson(json['fields']),
      geometry: Geometry.fromJson(json['geometry']),
      record_timestamp: json['record_timestamp']
    );
  }
}

class Geometry {
  final String? type;
  final List<double>? coordinates;

  Geometry({this.type, this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'],
      coordinates: json['coordinates'].cast<double>(),
    );
  }
}

class Trace {
  final String? route_long_name;
  final String? route_type;
  final String? id_ilico;
  final String? route_id;
  final String? networkname;
  final String? long_name_first;
  final Shape? shape;
  final String? operatorname;
  final String? route_color;
  final List<double>? geo_point_2d;
  final String? url;
  final String? route_short_name;

  Trace({this.route_long_name, this.route_type, this.id_ilico, this.route_id, this.networkname, this.long_name_first, this.shape, this.operatorname, this.route_color, this.geo_point_2d, this.url, this.route_short_name});

  factory Trace.fromJson(Map<String, dynamic> json) {
    return Trace(
      route_long_name: json['route_long_name'],
      route_type: json['route_type'],
      id_ilico: json['id_ilico'],
      route_id: json['route_id'],
      networkname: json['networkname'],
      long_name_first: json['long_name_first'],
      shape: Shape.fromJson(json['shape']),
      operatorname: json['operatorname'],
      route_color: json['route_color'],
      geo_point_2d: json['geo_point_2d'].cast<double>(),
      url: json['url'],
      route_short_name: json['route_short_name']
    );
  }
}

class Shape {
  final String? type;
  final List<List<List<double>>>? coordinates;

  Shape({this.type, this.coordinates});

  factory Shape.fromJson(Map<String, dynamic> json) {
    var coordinatesJson = json['coordinates'] as List;
    List<List<List<double>>> coordinates = coordinatesJson.map((coordinateJson) {
      return (coordinateJson as List).map((coordinatePairJson) {
        return (coordinatePairJson as List).map((coordinate) => coordinate as double).toList();
      }).toList();
    }).toList();
    return Shape(
      type: json['type'],
      coordinates: coordinates
    );
  }
}

class Traces {
  List<Trace> traces = [];

  void parseTraces(List<dynamic> data) {
    traces = [];
    for (var recordData in data) {
      try {
        RecordTrace record = RecordTrace.fromJson(recordData);
        traces.add(record.fields!);
      } catch (e) {
        print("Error : $e");
      
      }
    }
  }

  List<Trace> getTraces() {
    return traces;
  }
}