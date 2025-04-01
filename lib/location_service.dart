import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as permissionHandler;

class LocationService {
  LocationService._privateConstructor();

  static final _repository = LocationService._privateConstructor();

  static LocationService get instance => _repository;

  Function(bool hasPermission)? listenPermission;

  initial() async {
    Geolocator.getServiceStatusStream().listen((ServiceStatus event) async {
      // log.debug('getServiceStatusStream: ${event.name}');
      if (event == ServiceStatus.disabled) {
        openDialog(onONButtonClick: () async {
          Get.back();
          openLocationSettings();
        });
      }
    });
  }

  Position _lastKnowPosition = Position(
      heading: 0.0,
      timestamp: DateTime.now(),
      longitude: 0.0,
      speedAccuracy: 0.0,
      latitude: 0.0,
      altitude: 0.0,
      speed: 0.0,
      accuracy: 0.0, altitudeAccuracy: 0.0, headingAccuracy: 0.0);

  Position get getLastKnowPosition => _lastKnowPosition;

  _onNewLocationListener(Position position) {
    _lastKnowPosition = position;
  }

  bool isFinishRequestPermission = true;

  /// requestLocationPermission
  requestLocationPermission() async {
    isFinishRequestPermission = false;
    if (!(await Geolocator.isLocationServiceEnabled())) {
      openDialog(onONButtonClick: () async {
        isFinishRequestPermission = true;
        Get.back();
        openLocationSettings();
      });
    } else {
      var status = await permissionHandler.Permission.location.status;
      if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
        status = await permissionHandler.Permission.location.request();
      }

      if (status.isGranted || status.isLimited) {
        await getCurrentPosition();
        if (listenPermission != null) listenPermission!(true);
        isFinishRequestPermission = true;
      } else {
        if (listenPermission != null) listenPermission!(false);
        openDialog(onONButtonClick: () async {
          isFinishRequestPermission = true;
          Get.back();
          if (status.isPermanentlyDenied) {
            await Geolocator.openAppSettings();
          } else {
            requestLocationPermission();
          }
        });
      }
    }
  }

  // get CurrentPosition
  Future getCurrentPosition() async {
    bool _isError = false;
    await Geolocator.getCurrentPosition()
        .then((_position) => _onNewLocationListener(_position))
        .catchError((e) {
      // log.error('getCurrentPosition false: $e');
      _isError = true;
    });
    if (_isError)
      return false;
    else
      return _lastKnowPosition;
  }

  /// get LastKnowPosition
  getLastKnownPosition() async {
    await Geolocator.getLastKnownPosition().then((_position) {
      if (_position != null) _onNewLocationListener(_position);
    }).catchError((e) {
      // log.error('getLastKnownPosition false: $e');
      requestLocationPermission();
    });
    return _lastKnowPosition;
  }

  distanceBetween(double startLatitude, double startLongitude, double endLatitude,
      double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  openDialog({required Function() onONButtonClick}) {
    // CustomDialog.openDialog(
    //   title: 'confirm'.tr,
    //   contentText: 'turn_on_the_location'.tr,
    //   action: Row(
    //     mainAxisSize: MainAxisSize.max,
    //     children: [
    //       Spacer(),
    //       Flexible(
    //         flex: 3,
    //         child: CustomButton(
    //           // onPressed: () => GetPlatform.isIOS ? exit(0) : SystemNavigator.pop(),
    //           onPressed: Get.back,
    //           child: Center(
    //             child: Text(
    //               'close'.tr,
    //               style: CustomTextStyle.caption(height: 1.25, color: Colors.white),
    //             ),
    //           ),
    //           buttonSize: CustomButtonSize.small1,
    //           color: CustomColors.yellow,
    //         ),
    //       ),
    //       SizedBox(width: 20),
    //       Flexible(
    //         flex: 3,
    //         child: CustomButton(
    //           onPressed: onONButtonClick,
    //           child: Center(
    //             child: Text(
    //               'setting_gps_action'.tr,
    //               style: CustomTextStyle.caption(height: 1.25, color: Colors.white),
    //             ),
    //           ),
    //           buttonSize: CustomButtonSize.small1,
    //         ),
    //       ),
    //       Spacer(),
    //     ],
    //   ),
    // );
  }

  openLocationSettings() async {
    if (GetPlatform.isIOS) {
      final channel = const MethodChannel('openAppSetting');
      channel.invokeMethod('location');
    } else {
      await Geolocator.openLocationSettings();
    }
  }
}
