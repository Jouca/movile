class Stop {
  // stop_id,stop_code,stop_name,stop_desc,stop_lon,stop_lat,zone_id,stop_url,location_type,parent_station,stop_timezone,level_id,wheelchair_boarding,platform_code
  final String? stop_id;
  final String? stop_code;
  final String? stop_name;
  final String? stop_desc;
  final String? stop_lon;
  final String? stop_lat;
  final String? zone_id;
  final String? stop_url;
  final String? location_type;
  final String? parent_station;
  final String? stop_timezone;
  final String? level_id;
  final String? wheelchair_boarding;
  final String? platform_code;

  Stop({
    this.stop_id,
    this.stop_code,
    this.stop_name,
    this.stop_desc,
    this.stop_lon,
    this.stop_lat,
    this.zone_id,
    this.stop_url,
    this.location_type,
    this.parent_station,
    this.stop_timezone,
    this.level_id,
    this.wheelchair_boarding,
    this.platform_code
  });
}

class Stops {
  List<Stop> stops = [];

  List<Stop> getStops() {
    return stops;
  }

  void parseStops(List<dynamic> data) {
    for (var i = 1; i < data.length; i++) {
      var stop = Stop(
        stop_id: data[i][0].toString(),
        stop_code: data[i][1].toString(),
        stop_name: data[i][2].toString(),
        stop_desc: data[i][3].toString(),
        stop_lon: data[i][4].toString(),
        stop_lat: data[i][5].toString(),
        zone_id: data[i][6].toString(),
        stop_url: data[i][7].toString(),
        location_type: data[i][8].toString(),
        parent_station: data[i][9].toString(),
        stop_timezone: data[i][10].toString(),
        level_id: data[i][11].toString(),
        wheelchair_boarding: data[i][12].toString(),
        platform_code: data[i][13].toString()
      );
      stops.add(stop);
    }
  }
}