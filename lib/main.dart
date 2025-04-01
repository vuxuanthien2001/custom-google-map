import 'package:custom_google_map/custom_google_map.dart';
import 'package:custom_google_map/custom_google_map_controller.dart';
import 'package:custom_google_map/find_place_data.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String address = "Chưa có địa chỉ";
  var customGoogleMapController = CustomGoogleMapController();
  FindPlaceData currentPosition = FindPlaceData(lat: 0, lng: 0);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
    _setInitialPosition();
  }

  void _searchPosition(String address) async {
    try {
      if (address.isEmpty) {
        print("⚠️ Địa chỉ không được để trống!");
        _showErrorSnackbar("⚠️ Địa chỉ không được để trống!s");
        return;
      }

      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        print("⚠️ Không tìm thấy vị trí cho địa chỉ: $address");
        _showErrorSnackbar("⚠️ Không tìm thấy vị trí cho địa chỉ: $address", isSuccess: false);
        return;
      }

      double lat = locations[0].latitude;
      double lng = locations[0].longitude;
      print("📍 Vị trí tìm được: $lat, $lng");

      setState(() {
        currentPosition.lat = lat;
        currentPosition.lng = lng;
      });

      if (customGoogleMapController != null) {
        customGoogleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(lat, lng),
              zoom: 16, // Điều chỉnh mức zoom
            ),
          ),
        );
      } else {
        print("⚠️ Controller chưa khởi tạo!");
        _showErrorSnackbar("⚠️ Controller chưa khởi tạo!", isSuccess: false);
      }
    } catch (e) {
      print("❌ Lỗi khi tìm kiếm vị trí: $e");
      _showErrorSnackbar("❌ $e", isSuccess: false);
    }
  }

  void _showErrorSnackbar(
    String message, {
    bool isSuccess = true,
    Color? color,
    Duration? duration,
  }) {
    final backgroundColor =
        color ?? (isSuccess ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(milliseconds: 500),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        content: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Text(
              message,
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getAddress(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String address = [
          place.name,
          place.thoroughfare,
          place.subThoroughfare,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        return address;
      } else {
        return "Không tìm thấy địa chỉ.";
      }
    } catch (e) {
      return "$e";
    }
  }

  void _setInitialPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      setState(() {
        currentPosition.lat = position.latitude;
        currentPosition.lng = position.longitude;
      });

      customGoogleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPosition.lat, currentPosition.lng),
            zoom: 16, // Điều chỉnh mức zoom tùy thích
          ),
        ),
      );
    } catch (e) {
      print("Lỗi khi lấy vị trí: $e");
    }
  }

  void onUpdateAddress(FindPlaceData data) async {
    print("------ FETCHED ----");
    print("------- CURRENT LAT: ${data.lat} LONG: ${data.lng} -------");
    String newAddress = await getAddress(data.lat, data.lng);
    print("------- ADDRESS: $newAddress -------");

    setState(() {
      address = newAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: TextField(
          controller: _searchController,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _searchPosition(_searchController.text);
              },
            ),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) {
            // _searchPosition(value);
          },
        ),
      ),
      body: CustomGoogleMap(
        customGoogleMapController: customGoogleMapController,
        initialPosition: currentPosition,
        onUpdateAddress: onUpdateAddress,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                address,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
