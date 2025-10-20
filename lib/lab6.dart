import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:yandex_mapkit/yandex_mapkit.dart';

class ObjectsMapPage extends StatefulWidget {
  const ObjectsMapPage({
    super.key,
    required this.dataUrl,

    this.initialPoint = const Point(latitude: 55.751244, longitude: 37.618423),
    this.initialZoom = 10,
  });

  final String dataUrl;
  final Point initialPoint;
  final double initialZoom;

  @override
  State<ObjectsMapPage> createState() => _ObjectsMapPageState();
}

class _ObjectsMapPageState extends State<ObjectsMapPage> {
  final List<MapObject> _mapObjects = [];
  bool _isLoading = true;
  String? _error;
  YandexMapController? _controller;

  @override
  void initState() {
    super.initState();
    _fetchAndBuildPlacemarks();
  }

  Future<void> _fetchAndBuildPlacemarks() async {
    try {
      final uri = Uri.parse(widget.dataUrl);
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final List<dynamic> raw = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      final List<_Place> places = raw
        .map((e) => _Place.fromJson(e as Map<String, dynamic>))
        .where((p) => p.point != null)
        .toList();

      final List<MapObject> objects = <MapObject>[];
      for (int i = 0; i < places.length; i++) {
        final _Place place = places[i];
        final mapId = MapObjectId('place_$i');
        objects.add(
          PlacemarkMapObject(
            mapId: mapId,
            point: place.point!,
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('web/icons/gps.png'),
              ),
            ),
            onTap: (PlacemarkMapObject self, Point point) {
              _showPlaceDetails(place);
            },
          )
        );
      }

      setState(() {
        _mapObjects
          ..clear()
          ..addAll(objects);
        _isLoading = false;
        _error = null;
      });

      if (places.isNotEmpty && _controller != null) {
        await _controller!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: places.first.point!, zoom: widget.initialZoom),
          ),
          animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.3),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _showPlaceDetails(_Place place) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(place.name ?? 'Информация'),
          message: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (place.address != null) Text('Адрес: ${place.address}') else const SizedBox.shrink(),
              if (place.tel != null) Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Телефон: ${place.tel}'),
              ),
              if (place.point != null) Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Координаты: ${place.point!.latitude.toStringAsFixed(6)}, ${place.point!.longitude.toStringAsFixed(6)}'),
              ),
            ],
          ),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            isDefaultAction: true,
            child: const Text('Закрыть'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Ошибка: $_error'));
    }

    return YandexMap(
      onMapCreated: (YandexMapController controller) async {
        _controller = controller;
        if (_mapObjects.isEmpty) {
          await _controller!.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: widget.initialPoint, zoom: widget.initialZoom),
            ),
          );
        }
      },
      mapObjects: _mapObjects,
    );
  }
}

class _Place {
  _Place({
    this.name,
    this.address,
    this.tel,
    this.point,
  });

  final String? name;
  final String? address;
  final String? tel;
  final Point? point;

  static _Place fromJson(Map<String, dynamic> json) {
    final String? gps = json['gps'] as String?;
    Point? parsedPoint;
    if (gps != null) {
      final parts = gps.split(',');
      if (parts.length == 2) {
        final String latStr = parts[0].trim();
        final String lonStr = parts[1].trim();
        final double? lat = double.tryParse(latStr);
        final double? lon = double.tryParse(lonStr);
        if (lat != null && lon != null) {
          parsedPoint = Point(latitude: lat, longitude: lon);
        }
      }
    }

    return _Place(
      name: json['name'] as String?,
      address: json['address'] as String?,
      tel: json['tel'] as String?,
      point: parsedPoint,
    );
  }
}