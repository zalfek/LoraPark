import 'package:flutter/material.dart';
import 'package:lorapark_app/config/locations/sensor_locations.dart';
import 'package:lorapark_app/config/sensor_list.dart';
import 'package:lorapark_app/data/models/sensor.dart';

List<Sensor> personCountList = [
  Sensor(
    type: SensorType.person_count,
    id: SensorEndpoints.personCount_one,
    name: 'Person Count',
    number: '10',
    image: AssetImage('assets/images/person_count.png'),
    location: SensorLocations.personCount,
  )
];
