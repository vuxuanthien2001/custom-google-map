import 'dart:async';
import 'dart:ui' as ui;
import 'package:custom_google_map/custom_info_window.dart';
import 'package:custom_google_map/find_place_data.dart';
import 'package:custom_google_map/map_pin_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMapController {
  static CameraPosition kInitialPosition = const CameraPosition(
    target: LatLng(
      0,
      0,
    ),
    zoom: 17.0,
  );
  final customInfoWindowController = CustomInfoWindowController();
  final infoWindowController = CustomInfoWindowController();
  Completer<GoogleMapController> mapController = Completer();
  bool isMapCreated = false;
  bool isUpdateAddress = true;
  CameraPosition position = kInitialPosition;
  final markers = <Marker>[].obs;
  final polyline = <Polyline>[].obs;
  FindPlaceData? placeData;
  final mapPickerController = MapPickerController();

  Future<void> addMarker(String markerId, LatLng position, {Uint8List? icon}) async {
    late Marker marker;
    if (icon == null) {
      // ByteData data = await rootBundle.load((markerId == 'startPoint')
      //     ? 'assets/images/red_pin_marker.png'
      //     : 'assets/images/blue_pin_marker.png');
      // ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      //     targetWidth: 120, targetHeight: 120);
      // ui.FrameInfo fi = await codec.getNextFrame();
      // icon = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      //     .buffer
      //     .asUint8List();

      // marker = Marker(
      //   markerId: MarkerId(markerId),
      //   icon: BitmapDescriptor.fromBytes(icon),
      //   position: position,
      // );
    } else {
      marker = Marker(
        markerId: MarkerId(markerId),
        icon: BitmapDescriptor.fromBytes(icon),
        position: position,
      );
    }
    for (int i = 0; i < markers.length; i++) {
      if (markers[i].markerId.value == markerId) {
        markers.replaceRange(i, i, [marker]);
        markers.refresh();
        return;
      }
    }
    markers.add(marker);
  }

  List<Marker> get getMarkers => markers;

  void removeMarker(String markerId) {
    markers.removeWhere((element) => element.markerId.value == markerId);
  }

  void removePolyline(String polylineId) {
    polyline.removeWhere((element) => element.polylineId.value == polylineId);
    customInfoWindowController.hideInfoWindow!();
  }

  void visibleMapPicker(bool visible) {
    if (visible) {
      mapPickerController.visible();
      isUpdateAddress = true;
    } else {
      isUpdateAddress = false;
      mapPickerController.hide();
    }
  }

  Future<void> animateCamera(CameraUpdate cameraUpdate,
      [FindPlaceData? placeData]) async {
    await (await mapController.future).animateCamera(cameraUpdate);
    this.placeData = placeData;
  }
}
