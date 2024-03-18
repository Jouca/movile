import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:movile/extensions.dart';
import 'dart:core';
import 'pageSelectTrip.dart';
import 'pageStation.dart';
import 'IDFMData/lineTrip.dart';
import 'IDFMData/stopTimes.dart';
import 'IDFMData/lines.dart';
import 'IDFMData/traces.dart';
import 'main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PageScreenMetro extends StatefulWidget {
  const PageScreenMetro({super.key});

  @override
  State<PageScreenMetro> createState() => PageScreenMetroState();
}

class PageScreenMetroState extends State<PageScreenMetro> with TickerProviderStateMixin {
  List<LineTrip> lineTrips = [];
  LineTrip lineTripSelected = LineTrip();
  var distanceStation = 200;
  var KeepedDistance = 0.0;
  var distance;
  var datetimehour = DateTime.now().hour.toString().padLeft(2, '0');
  var datetimeminute = DateTime.now().minute.toString().padLeft(2, '0');
  double opacity_datetime = 1.0;

  bool waitRemove = false;

  List<ListTile> stationsTiles = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;
  String? _newVoiceText;
  int? _inputLength;
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  String stationCurrentHere = "";
  static String stationCurrentID = "";
  int currentIndex = 0;

  bool toastSubmitted = false;

  Timer TimerupdateTime = Timer.periodic(const Duration(seconds: 1), (timer) => {});
  Timer TimertestOnStationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) => {});

  DateTime convertStringToDateTime(String time) {
    var timeSplit = time.split(":");
    var today = DateTime.now();
    if (int.parse(timeSplit[0]) >= 24) {
      // add a day
      today = today.add(const Duration(days: 1));
      // change the hour
      timeSplit[0] = (int.parse(timeSplit[0]) - 24).toString();
    }
    var newTime = DateTime(today.year, today.month, today.day, int.parse(timeSplit[0]), int.parse(timeSplit[1]), int.parse(timeSplit[2]));
    return newTime;
  }

  void updateTime() {
    setState(() {
      datetimehour = DateTime.now().hour.toString().padLeft(2, '0');
      datetimeminute = DateTime.now().minute.toString().padLeft(2, '0');
    });

    if (opacity_datetime == 1.0) {
      setState(() {
        opacity_datetime = 0.7;
      });
    } else {
      setState(() {
        opacity_datetime = 1.0;
      });
    }
  }

  void testOnStationCoordinates() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    _getCurrentPosition().then((value) async {
      for (int i = 0; i < lineTripSelected.getStations().length; i++) {
        var stopTimes = lineTripSelected.getStations()[i];
        // test if a station is around 100 meters of the user
        if (PageSelectTripState.isGeographic) {
          var stop = MyAppState.stops_data.firstWhere((element) => element.stop_id == stopTimes.stop_id);
          distance = Geolocator.distanceBetween(
            double.parse(_positionItems.last.displayValue.split("Latitude: ")[1].split(", Longitude: ")[0]),
            double.parse(_positionItems.last.displayValue.split("Longitude: ")[1]),
            lineTripSelected.getCoordinates()[i][1],
            lineTripSelected.getCoordinates()[i][0]
          );

          switch(lineTripSelected.getTransportTypeName()) {
            case "Métro":
              distanceStation = 100;
              break;
            case "Tramway":
              distanceStation = 50;
              break;
            case "Transilien":
              distanceStation = 200;
              break;
            case "Train":
              distanceStation = 200;
              break;
            case "RER":
              distanceStation = 150;
              break;
            default:
              distanceStation = 50;
              break;
          }

          if (distance <= distanceStation) {
            if (!waitRemove) {
              currentIndex = i;
            }

            setState(() {
              stationCurrentHere = MyAppState.stops_data.firstWhere((element) => element.stop_id == stopTimes.stop_id).stop_name!;
              stationCurrentID = stopTimes.stop_id!;
            });

            _newVoiceText = stationCurrentHere;
            pushAnimationStation();
          } else if (waitRemove) {
            pushAnimationStation();
          }
        }
      }
    });
  }

  void TestOnStationTime() {
    var today = DateTime.now();
    for (int i = 0; i < lineTripSelected.getDepartureTimes().length; i++) {
      var stopTimes = lineTripSelected.getStations()[i];
      var departureTime = lineTripSelected.getDepartureTimes()[i];
      if (today.isAfter(departureTime)) {
        if (!waitRemove) {
          currentIndex = i;
          setState(() {
            stationCurrentHere = MyAppState.stops_data.firstWhere((element) => element.stop_id == stopTimes.stop_id).stop_name!;
            stationCurrentID = stopTimes.stop_id!;
          });
        }

        _newVoiceText = stationCurrentHere;
        pushAnimationStation();
      } else if (waitRemove) {
        pushAnimationStation();
      }
    }
  }

  void popStationTile() {
    int intRemove = 0;
    if (PageSelectTripState.isGeographic) {
      intRemove = lineTripSelected.update(stationCurrentID) + 1;
    } else if (PageSelectTripState.isTime) {
      intRemove = lineTripSelected.updateDateTime(DateTime.now());
    }

    stationCurrentID = lineTripSelected.getStations()[0].stop_id!;

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    for (int i = 0; i < intRemove; i++) {
      // remove also on the list
      var item = stationsTiles.removeAt(0);

      builder(context, animation) {
        // Apply an ease in and out curve to the animation.
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SizeTransition(
            sizeFactor: curvedAnimation,
            child: item,
          ),
        );
      }
      _listKey.currentState!.removeItem(0, builder, duration: const Duration(seconds: 1));
    }

    waitRemove = false;
  }

  late AnimationController _animationController;
  late Animation<double> _animation;

  void pushAnimationStation() async {
    if (!waitRemove) {
      await _speak();
      _animationController.forward();
      waitRemove = true;
    }

    if (PageSelectTripState.isGeographic) {
      _getCurrentPosition().then((value) async {
        KeepedDistance = Geolocator.distanceBetween(
          double.parse(_positionItems.last.displayValue.split("Latitude: ")[1].split(", Longitude: ")[0]),
          double.parse(_positionItems.last.displayValue.split("Longitude: ")[1]),
          lineTripSelected.getCoordinates()[currentIndex][1],
          lineTripSelected.getCoordinates()[currentIndex][0]
        );
      });
      if (KeepedDistance > distanceStation) {
        removeAnimationStation().then((value) {
          popStationTile();
          KeepedDistance = 0.0;
        }).catchError((error) {
          print('An error occurred: $error');
        });
      }
    } else if (PageSelectTripState.isTime) {
      await Future.delayed(Duration(seconds: 10));
      try {
        stationCurrentID = lineTripSelected.getStations()[currentIndex].stop_id!;
      } catch (e) {
        stationCurrentID = "";
      }
      removeAnimationStation().then((value) {
        popStationTile();
      }).catchError((error) {
        print('An error occurred: $error');
      });
    }
    
  }

  TickerFuture removeAnimationStation() {
    return _animationController.reverse();
  }

  @override
  void dispose() {
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }

    TimerupdateTime.cancel();
    TimertestOnStationTimer.cancel();

    flutterTts.stop();

    super.dispose();
  }

  void showToastMessageTimeWait(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  @override
  void initState() {
    super.initState();

    initTts();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Création des LineTrips
    for (var stationTime in PageSelectTripState.stationTimesSelected!) {
      List<StopTime> stopTimes = [];
      List<DateTime> departureTimes = [];
      List<List<double>> geoPoints = [];
      String routeID = "";
      String tripID = "";
      String route_type = "";
      String tripHeadSign = PageSelectTripState.stationNameSelected;
      for (var stopTime in stationTime) {
        stopTimes.add(stopTime.values.first.first);
        departureTimes.add(convertStringToDateTime(stopTime.values.first.first.departure_time!));
        tripID = stopTime.values.first.first.trip_id!;
        routeID = MyAppState.selectedLine.route_id!;
        route_type = MyAppState.selectedLine.route_type!;
      }
      lineTrips.add(LineTrip(
        route_ID: routeID,
        trip_ID: tripID,
        trip_headsign: tripHeadSign,
        departure_times: departureTimes,
        stations: stopTimes,
        route_type: route_type
      ));
    }

    if (PageSelectTripState.isGeographic) {
      lineTripSelected = lineTrips.first;
    } else if (PageSelectTripState.isTime) {
      // Get the first trip with the next departure time based on the current time
      var today = DateTime.now();
      var nextDeparture = DateTime(3000, 1, 1);
      for (var lineTrip in lineTrips) {
        if (lineTrip.departure_times!.first.isAfter(today) && lineTrip.departure_times!.first.isBefore(nextDeparture)) {
          nextDeparture = lineTrip.departure_times!.first;
          lineTripSelected = lineTrip;
        }
      }
    }


    List<StopTime> stopTimes = lineTripSelected.getStations();
    stationCurrentID = stopTimes.first.stop_id!;

    int count = 0;
    for (var stopTime in stopTimes) {
      StationTile stationTile = StationTile(stationID: stopTime.stop_id!);

      lineTripSelected.addCoordinates(stopTime.stop_id!);
      if (count == stopTimes.length - 1) {
        stationsTiles.add(
          ListTile(
            tileColor: Colors.transparent,
            title: Container(
              height: 100,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: stationTile
                  ),
                  Container(
                    width: 500,
                    padding: const EdgeInsets.only(left: 10),
                    child: AutoSizeText(
                      MyAppState.stops_data.firstWhere((element) => element.stop_id == stopTime.stop_id).stop_name!,
                      minFontSize: 30,
                      maxFontSize: 60,
                      style: const TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.black,
                        fontSize: 60,
                        fontFamily: "Parisine",
                        fontWeight: FontWeight.bold
                      ),
                      maxLines: 2,
                      wrapWords: false,
                    ),
                  ),
                ]
              )
            )
          )
        );
      } else {
        stationsTiles.add(
          ListTile(
            tileColor: Colors.transparent,
            title: Container(
              height: 100,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: stationTile
                  ),
                  Container(
                    width: 500,
                    padding: const EdgeInsets.only(left: 10),
                    child: AutoSizeText(
                      MyAppState.stops_data.firstWhere((element) => element.stop_id == stopTime.stop_id).stop_name!,
                      minFontSize: 30,
                      maxFontSize: 60,
                      style: const TextStyle(
                        color: Color.fromRGBO(5, 13, 158, 1),
                        fontSize: 60,
                        fontFamily: "Parisine",
                        fontWeight: FontWeight.bold
                      ),
                      maxLines: 2,
                      wrapWords: false,
                    ),
                  ),
                ]
              )
            )
          )
        );
      }
      count++;
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);

    if (PageSelectTripState.isGeographic) {
      _toggleServiceStatusStream();
      const millseconds = Duration(milliseconds: 100);
      TimertestOnStationTimer = Timer.periodic(millseconds, (timer) => testOnStationCoordinates());
    } else if (PageSelectTripState.isTime) {
      const millseconds = Duration(milliseconds: 100);
      TimertestOnStationTimer = Timer.periodic(millseconds, (timer) => TestOnStationTime());
    }

    setState(() => MyAppState.canPop = true);

    const oneSec = Duration(seconds:1);
    TimerupdateTime = Timer.periodic(oneSec, (timer) => updateTime());
  }

  @override
  Widget build(BuildContext context) {
    var transportLogo = Container(
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Center(child: MyAppState.selectedLine.getLineIcon(2.0)),
          Container(
            width: 400,
            child: AutoSizeText(
              PageSelectTripState.stationNameSelected,
              maxFontSize: 60,
              minFontSize: 30,
              maxLines: 2,
              style: const TextStyle(
                color: Color.fromRGBO(5, 13, 158, 1),
                fontFamily: "Parisine",
                fontWeight: FontWeight.bold
              )
            )
          )
        ],
      ),
    );

    double appbar_height = 80;

    if (PageSelectTripState.isTime && !toastSubmitted) {
      showToastMessageTimeWait("Prochain départ : ${lineTripSelected.getStations()[0].departure_time!}");
      toastSubmitted = true;
    }
    
    return PopScope(
      canPop: MyAppState.canPop,
      child: MaterialApp(
        title: 'Movile',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: appbar_height,
            elevation: 5, 
            backgroundColor: Colors.white,
            shadowColor: Colors.black,
            titleSpacing: 0,
            
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                transportLogo,
                Container(
                  width: 160,
                  height: appbar_height,
                  color: Colors.black,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          datetimehour,
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 40,
                            fontFamily: "Parisine",
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          ":",
                          style: TextStyle(
                            color: Color.fromRGBO(251, 255, 0, opacity_datetime),
                            fontSize: 40,
                            fontFamily: "Parisine",
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          datetimeminute,
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 40,
                            fontFamily: "Parisine",
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]
                    )
                  ),
                ),
              ],
            )
          ),
          body: Stack(
            children: [
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                padding: const EdgeInsets.only(left: 30),
                color: "#cdc3bb".toColor(),
                child: Stack(
                  children: [
                    Container(
                      width: 25,
                      height: double.maxFinite,
                      color: MyAppState.selectedLine.route_color!.toColor(),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: Icon(
                              Icons.arrow_downward,
                              color: MyAppState.selectedLine.route_text_color!.toColor(),
                              size: 25,
                            ),
                          ),
                          ///////////////////////
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 50, top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Prochain arrêts",
                            style: TextStyle(
                              fontFamily: "Parisine",
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: "#777779".toColor()
                            )
                          ),
                          // test if the list is empty
                        ],
                      )
                    )
                  ],
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 250,
                width: 600,
                padding: EdgeInsets.only(top: 40, left: 6),
                child: Container(
                  color: Colors.transparent,
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: stationsTiles.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: const Offset(0, 0),
                        ).animate(animation),
                        child: stationsTiles[index],
                      );
                    },
                  )
                )
              ),
              FadeTransition(
                opacity: _animation,
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    color: Color.fromRGBO(5, 13, 158, 1),
                    child: SizedBox(
                      width: 650,
                      height: 300,
                      child: Center(child: AutoSizeText(
                        stationCurrentHere,
                        maxFontSize: 110,
                        minFontSize: 50,
                        maxLines: 2,
                        wrapWords: false,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Parisine",
                          fontSize: 110,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ))
                    )
                  )
                )
              ),
            ]
          )
        )
      )
    );
  }

  // -------------------------- GEOLOCATION PART --------------------------
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    _updatePositionList(
      _PositionItemType.position,
      position.toString(),
    );
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      _PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }


  bool _isListening() => !(_positionStreamSubscription == null || _positionStreamSubscription!.isPaused);

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    setState(() {});
  }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;
        if (serviceStatus == ServiceStatus.enabled) {
          if (positionStreamStarted) {
            _toggleListening();
          }
          serviceStatusValue = 'enabled';
        } else {
          if (_positionStreamSubscription != null) {
            setState(() {
              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;
              _updatePositionList(
                  _PositionItemType.log, 'Position Stream has been canceled');
            });
          }
          serviceStatusValue = 'disabled';
        }
        _updatePositionList(
          _PositionItemType.log,
          'Location service has been $serviceStatusValue',
        );
      });
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => _updatePositionList(
            _PositionItemType.position,
            position.toString(),
          ));
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      _updatePositionList(
        _PositionItemType.log,
        'Listening for position updates $statusDisplayValue',
      );
    });
  }


  void _getLastKnownPosition() async {
    final position = await _geolocatorPlatform.getLastKnownPosition();
    if (position != null) {
      _updatePositionList(
        _PositionItemType.position,
        position.toString(),
      );
    } else {
      _updatePositionList(
        _PositionItemType.log,
        'No last known position available',
      );
    }
  }

  void _getLocationAccuracy() async {
    final status = await _geolocatorPlatform.getLocationAccuracy();
    _handleLocationAccuracyStatus(status);
  }

  void _requestTemporaryFullAccuracy() async {
    final status = await _geolocatorPlatform.requestTemporaryFullAccuracy(
      purposeKey: "TemporaryPreciseAccuracy",
    );
    _handleLocationAccuracyStatus(status);
  }

  void _handleLocationAccuracyStatus(LocationAccuracyStatus status) {
    String locationAccuracyStatusValue;
    if (status == LocationAccuracyStatus.precise) {
      locationAccuracyStatusValue = 'Precise';
    } else if (status == LocationAccuracyStatus.reduced) {
      locationAccuracyStatusValue = 'Reduced';
    } else {
      locationAccuracyStatusValue = 'Unknown';
    }
    _updatePositionList(
      _PositionItemType.log,
      '$locationAccuracyStatusValue location accuracy granted.',
    );
  }


  // ------------------------- GESTION DU TTS -------------------------

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();
    _getDefaultEngine();
    _getDefaultVoice();

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setInitHandler(() {
      setState(() {
        print("TTS Initialized");
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }
}

// -------------------------- STATION TILE ANIMATION --------------------------

class StationTile extends StatefulWidget {
  StationTile({super.key, required this.stationID});

  String stationID = "";

  @override
  State<StationTile> createState() => _StationTileState();
}

class _StationTileState extends State<StationTile> with TickerProviderStateMixin {
  var TimerStationAnimation;
  var index = 0;

  bool triggered = false;

  List<Image> images = [
    Image.asset("assets/images/tiles/metro_station.png"),
    Image.asset("assets/images/tiles/metro_station_check.png"),
  ];

  late final AnimationController _controller;
  late final Animation<int> _animation;

  void animateUpdate() {
    if (widget.stationID == PageScreenMetroState.stationCurrentID) {
      if (!triggered && _controller.isAnimating) {
        _controller.repeat();
        triggered = true;
      }
    } else {
      if (!triggered && _controller.isAnimating) {
        _controller.stop(canceled: false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Change the duration as needed
      vsync: this,
    )..repeat();
    _animation = IntTween(begin: 0, end: images.length - 1).animate(_controller);

    Timer TimerupdateTime = Timer.periodic(const Duration(seconds: 1), (timer) => animateUpdate());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Image.asset("assets/images/tiles/metro_station.png"), // Replace with your default image path
            if (_controller.isAnimating)
              images[_animation.value],
          ],
        );
      },
    );
  }
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

enum TtsState { playing, stopped, paused, continued }