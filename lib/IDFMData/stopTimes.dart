class StopTime {
  final String? trip_id;
  final String? arrival_time;
  final String? departure_time;
  final String? stop_id;
  final String? stop_sequence;
  final String? pickup_type;
  final String? drop_off_type;
  final String? local_zone_id;
  final String? stop_headsign;
  final String? timepoint;

  StopTime({
    this.trip_id,
    this.arrival_time,
    this.departure_time,
    this.stop_id,
    this.stop_sequence,
    this.pickup_type,
    this.drop_off_type,
    this.local_zone_id,
    this.stop_headsign,
    this.timepoint
  });

  factory StopTime.fromJson(Map<String, dynamic> json) {
    return StopTime(
      trip_id: json['trip_id'],
      arrival_time: json['arrival_time'],
      departure_time: json['departure_time'],
      stop_id: json['stop_id'],
      stop_sequence: json['stop_sequence'],
      pickup_type: json['pickup_type'],
      drop_off_type: json['drop_off_type'],
      local_zone_id: json['local_zone_id'],
      stop_headsign: json['stop_headsign'],
      timepoint: json['timepoint']
    );
  }
}

class StopTimes {
  List<Map<String, List<StopTime>>> stop_times = [];

  List<Map<String, List<StopTime>>> getStopTimes() {
    return stop_times;
  }

  void parseStopTimes(List<dynamic> data) {
    for (var i = 1; i < data.length; i++) {
      var stop_time = StopTime(
        trip_id: data[i][0].toString(),
        arrival_time: data[i][1].toString(),
        departure_time: data[i][2].toString(),
        stop_id: data[i][3].toString(),
        stop_sequence: data[i][4].toString(),
        pickup_type: data[i][5].toString(),
        drop_off_type: data[i][6].toString(),
        local_zone_id: data[i][7].toString(),
        stop_headsign: data[i][8].toString(),
        timepoint: data[i][9].toString()
      );

      stop_times.add({data[i][0].toString(): [stop_time]});
    }
  }
}