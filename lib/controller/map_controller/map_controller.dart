import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:logger/logger.dart';
import 'package:lorapark_app/config/sensors.dart';
import 'package:lorapark_app/data/models/coordinates.dart';
import 'package:lorapark_app/data/models/sensor.dart';
import 'package:lorapark_app/services/location_service/location_service.dart';
import 'package:lorapark_app/services/logging_service/logging_service.dart';

enum MapPageState { MAP_LOADING, MAP_ERROR, MAP_LOADED, ROUTING }
enum BottomSheetState { HIDDEN, SHOWING }

class MapController extends ChangeNotifier {
  final Logger _logger =
  GetIt.I.get<LoggingService>().getLogger((MapController).toString());

  final LocationService _locationService = GetIt.I.get<LocationService>();
  MapPageState _pageState = MapPageState.MAP_LOADING;
  BottomSheetState _bottomSheetState = BottomSheetState.HIDDEN;

  // Tap
  BottomSheetState get sheetState => _bottomSheetState;
  MapPageState get pageState => _pageState;

  // Tap
  List<Sensor> _bottomSheetSensorList = <Sensor>[];
  List<Sensor> get bottomSheetSensorList => _bottomSheetSensorList;

  HereMapController _hereMapController;

  HereMapController get hereMapController => _hereMapController;

  MapMarker userMapMarker;

  final MapImage _sensorMapIcon = MapImage.withFilePathAndWidthAndHeight(
      'assets/icons/png/location-outline.png', 72, 72);
  final MapImage userMapIcon = MapImage.withFilePathAndWidthAndHeight(
      'assets/icons/svg/ellipse-outline.svg', 36, 36);

  void onMapCreated(HereMapController hereMapController) async {
    _hereMapController = hereMapController;
    if (_locationService.location == null) {
      await _locationService.getLocation();
    } else {
      _logger.e('WARNING: LOCATION ISNT NULL');
    }
    _hereMapController.mapScene.loadSceneForMapScheme(MapScheme.greyDay,
            (MapError error) {
          if (error != null) {
            _logger.e('FATAL ERROR: Map was unable to be loaded');
            _logger.e('Map Error: $error');
            setPageState(MapPageState.MAP_ERROR);
            return;
          }
          const distanceInMeters = 5000.0;
          _logger.d(
              'Setting location to ${_locationService.location.latitude}, ${_locationService.location.longitude}');
          _hereMapController.camera.lookAtPointWithDistance(
              GeoCoordinates(_locationService.location.latitude,
                  _locationService.location.longitude),
              distanceInMeters);
          for (var sensor in GetIt.I.get<Sensors>().list) {
            var marker = MapMarker.withAnchor(
                GeoCoordinates(sensor.latitude, sensor.longitude),
                _sensorMapIcon,
                Anchor2D());

            // Tapping on Sensor
            var metadata = Metadata();
            metadata.setString('number', sensor.number);
            metadata.setDouble('long', sensor.longitude);
            metadata.setDouble('lat', sensor.latitude);
            marker.metadata = metadata;

            _hereMapController.mapScene.addMapMarker(marker);
          }
          setPageState(MapPageState.MAP_LOADED);
          _setTapGestureHandler();
        });
  }

  void setPageState(MapPageState pageState) {
    _pageState = pageState;
    notifyListeners();
  }

  // Tap
  void toggleBottomSheet() {
    if (_bottomSheetState == BottomSheetState.HIDDEN) {
      _bottomSheetState = BottomSheetState.SHOWING;
    } else {
      _bottomSheetState = BottomSheetState.HIDDEN;
      _bottomSheetSensorList.clear();
    }
    notifyListeners();
  }

  // Tap
  void _setTapGestureHandler() {
    _hereMapController.gestures.tapListener = TapListener.fromLambdas(
        lambda_onTap: (Point2D touchPoint) => _pickSensorOnMap(touchPoint));
  }

  // Tap
  void _pickSensorOnMap(Point2D touchPoint) {
    var radiusInPixel = 2.0;
    _hereMapController.pickMapItems(touchPoint, radiusInPixel,
            (sensorPickResult) {
          var sensorMarkerList = sensorPickResult.markers;
          if (sensorMarkerList.isEmpty) return;
          var topMostSensor = sensorMarkerList.first;
          var metadata = topMostSensor.metadata;
          if (metadata != null) {
            if(metadata.getString('number') == '') return;
            var location = SensorLocation(
                metadata.getDouble('lat'), metadata.getDouble('long'));
            for (var sensor in GetIt.I.get<Sensors>().list) {
              if (sensor.location == location && sensor.number.isNotEmpty) {
                _bottomSheetSensorList.add(sensor);
              }
            }
            toggleBottomSheet();
          }
        });
  }
}
