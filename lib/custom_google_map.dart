import 'package:custom_google_map/custom_google_map_controller.dart';
import 'package:custom_google_map/custom_marker.dart';
import 'package:custom_google_map/find_place_data.dart';
import 'package:custom_google_map/map_pin_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatelessWidget {
  const CustomGoogleMap(
      {super.key,
      required this.customGoogleMapController,
      required this.onUpdateAddress,
      required this.initialPosition});

  final Function(FindPlaceData data) onUpdateAddress;

  final CustomGoogleMapController customGoogleMapController;

  final FindPlaceData initialPosition;

  void _onMapCreated(GoogleMapController controller) {
    customGoogleMapController.mapController.complete(controller);
    customGoogleMapController.customInfoWindowController.googleMapController =
        controller;
    customGoogleMapController.infoWindowController.googleMapController =
        controller;
    if (!customGoogleMapController.isMapCreated) {
      customGoogleMapController.isMapCreated = true;

      customGoogleMapController.position = CameraPosition(
          target: LatLng(initialPosition.lat, initialPosition.lng), zoom: 17);
      customGoogleMapController.animateCamera(
          CameraUpdate.newCameraPosition(customGoogleMapController.position));
    }
  }

  void _updateCameraPosition(CameraPosition position) {
    // if (customGoogleMapController.isUpdateAddress) {
    //   onUpdateAddress(FindPlaceData(lng: position.target.longitude, lat: position.target.latitude));
    // }
    customGoogleMapController.position = position;
  }

  void _onCameraMoveStarted() =>
      customGoogleMapController.mapPickerController.mapMoving();

  void _onCameraIdle() {
    customGoogleMapController.mapPickerController.mapFinishedMoving();
    if (customGoogleMapController.isUpdateAddress) {
      onUpdateAddress(FindPlaceData(
          lng: customGoogleMapController.position.target.longitude,
          lat: customGoogleMapController.position.target.latitude));
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return MapPicker(
        mapPickerController: customGoogleMapController.mapPickerController,
        showDot: true,
        iconWidget: Obx(
          () => CustomMarker(
            color: customGoogleMapController.markers
                    .any((e) => e.markerId.value == 'startPoint')
                ? Colors.blue
                : Colors.red,
          ),
        ),
        child:
            GoogleMap(
          buildingsEnabled: false,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              initialPosition.lat,
              initialPosition.lng,
            ),
            zoom: 17.0,
          ),
          onCameraMove: _updateCameraPosition,
          onCameraMoveStarted: _onCameraMoveStarted,
          onCameraIdle: _onCameraIdle,
          // zoomControlsEnabled: false,
          markers: Set<Marker>.of(customGoogleMapController.markers),
          polylines: Set<Polyline>.of(customGoogleMapController.polyline),
        ));
  }
}
