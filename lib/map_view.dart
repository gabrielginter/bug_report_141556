import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_marker.dart';

class MapView extends StatefulWidget {
  const MapView({
    Key? key,
  }) : super(key: key);

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  GoogleMapController? _mapController;

  late Set<Polygon> polygonList;
  late Set<Marker> markerList = {};
  final LatLng initialCoords = const LatLng(0, 0);

  Map<int, LatLng> get points => {
    1: LatLng(-dgConst * 1.4, -dgConst * 1.4),
    2: LatLng(dgConst * 1.4, -dgConst * 1.4),
    3: LatLng(dgConst * 1.4, dgConst * 1.4),
    4: LatLng(-dgConst * 1.4, dgConst * 1.4),
  };

  final dgConst = 0.014017; // just a random small distance
  @override
  void initState() {
    // POLYGON generation
    polygonList = points.entries.map((c) => Polygon(
      polygonId: _getPolyId(c.key),
      points: [
        LatLng(c.value.latitude - dgConst, c.value.longitude - dgConst),
        LatLng(c.value.latitude + dgConst, c.value.longitude - dgConst),
        LatLng(c.value.latitude + dgConst, c.value.longitude + dgConst),
        LatLng(c.value.latitude - dgConst, c.value.longitude + dgConst),
        LatLng(c.value.latitude - dgConst, c.value.longitude - dgConst),
      ],
      fillColor: Colors.grey.withOpacity(.7),
      strokeColor: Colors.yellow,
      strokeWidth: 1,
    )).toSet();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());

    super.initState();
  }
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    var markers = <Marker>{};
    for (var c in points.entries) {
      // [MapMarkerPlus] is my own class that I use to draw a custom marker with a number in the center

      final marker = await MapMarkerPlus.buildLabelMarker(
        label: c.key.toString(),
        markerId: _getMarkerId(c.key),
        position: c.value,
        alpha: c.key == 1 ? 1.0 : .6,
        zIndex: 1 + c.key.toDouble(),
      );

      markers.add(marker);
    }

    setState(() {
      markerList = markers;
    });
  }

  PolygonId _getPolyId(int crag) => PolygonId('Poly_$crag');
  MarkerId _getMarkerId(int crag) => MarkerId('Marker_$crag');

  AppBar get _appBar => AppBar(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    centerTitle: true,
    title: const Text(
      'Map view',
      style: TextStyle(
        fontSize: 19.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 250));

      return markerList.isEmpty;
    });
  }
  Widget _getBody() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
      initialCameraPosition: CameraPosition(target: initialCoords, zoom: 10),
      mapType: MapType.hybrid,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      polygons: polygonList,
      markers: markerList,
      compassEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      padding: const EdgeInsets.only(bottom: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: _getBody(),
    );
  }
}