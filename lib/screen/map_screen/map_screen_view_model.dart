import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/map_screen/widgets/custom_marker.dart';
import 'package:orange_ui/screen/map_screen/widgets/user_pop_up.dart';
import 'package:orange_ui/service/pref_service.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:stacked/stacked.dart';

class MapScreenViewModel extends BaseViewModel {
  int selectedDistance = 1;
  List<int> distanceList = [1, 5, 10, 20, 50, 500];
  LatLng center = const LatLng(21.2408, 72.8806);
  List<RegistrationUserData> userList = [];
  Set<Marker> marker = {};
  List<Place> items = [];
  late GoogleMapController mapController;
  late cluster.ClusterManager manager;
  late Position position;
  List<Widget> widgets = [];
  Map<String, GlobalKey> globalKey = <String, GlobalKey>{};

  void init() {
    selectedDistance = distanceList.first;
    notifyListeners();
    manager = _initClusterManager();
  }

  cluster.ClusterManager _initClusterManager() {
    return cluster.ClusterManager<Place>(
      items,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      stopClusteringZoom: 17.0,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    marker = markers;
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) async {
    position = await getUserCurrentLocation();
    getUserByCoordinatesApiCall(latitude: position.latitude, longitude: position.longitude, km: selectedDistance);
    updateProfile();
    await PrefService.setLatitude(position.latitude.toString());
    await PrefService.setLongitude(position.longitude.toString());
    center = LatLng(position.latitude, position.longitude);
    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: 15.09)));
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(center));
    notifyListeners();
  }

  void updateProfile() async {
    await ApiProvider().updateProfile(latitude: '${position.latitude}', longitude: '${position.longitude}');
  }

  void onDistanceChange(int value) async {
    CommonUI.lottieLoader();
    position = await getUserCurrentLocation();
    selectedDistance = value;
    getUserByCoordinatesApiCall(latitude: position.latitude, longitude: position.longitude, km: selectedDistance);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: getZoomLevel(value.toDouble()))));
    Get.back();
    notifyListeners();
  }

  Future<void> getUserByCoordinatesApiCall(
      {required double latitude, required double longitude, required int km}) async {
    ApiProvider().getUserByLatLong(latitude: latitude, longitude: longitude, km: km).then((value) async {
      userList = value.data ?? [];
      items = [];
      widgets = List.generate(
        userList.length,
        (index) {
          String imageUrl = CommonFun.getProfileImage(images: userList[index].images);
          GlobalKey globalKey1 = GlobalKey();
          if (imageUrl.isEmpty) {
            globalKey[userList[index].fullname ?? '$index'] = globalKey1;
          } else {
            globalKey[imageUrl] = globalKey1;
          }
          return CustomMarker(
              imageUrl: imageUrl, globalKey: globalKey1, name: CommonUI.fullName(userList[index].fullname));
        },
      );
      for (int i = 0; i < userList.length; i++) {
        items.add(Place(
          userData: userList[i],
          latLng: LatLng(double.parse(userList[i].latitude ?? '0.0'), double.parse(userList[i].longitude ?? '0.0')),
        ));
      }
      manager.setItems(items);
      notifyListeners();
    });
  }

  double getZoomLevel(double radius) {
    double zoomLevel = 11;
    if (radius > 0) {
      double radiusElevated = radius + radius;
      zoomLevel = 16 - log(radiusElevated) / log(2);
    }
    zoomLevel = double.parse(zoomLevel.toStringAsFixed(2));
    return zoomLevel;
  }

  Future<Marker> Function(cluster.Cluster<Place>) get _markerBuilder => (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            for (var user in cluster.items) {
              cluster.isMultiple
                  ? mapController.animateCamera(CameraUpdate.zoomIn())
                  : Get.dialog(UserPopUp(user: user.userData), barrierColor: Colors.transparent);
            }
          },
          icon: await _getMarkerBitmap(
            cluster.isMultiple ? 50 : 80,
            cluster.items.toList(),
            text: cluster.isMultiple ? cluster.count.toString() : null,
          ),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, List<Place> places, {String? text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = ColorRes.darkOrange;
    final Paint paint2 = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: size / 3, color: Colors.white, fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(canvas, Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2));
    }
    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;
    if (size == 80) {
      return await MarkerIcon.widgetToIcon(globalKey[
          CommonFun.getProfileImage(images: places[0].userData?.images).isEmpty
              ? places[0].userData?.fullname
              : CommonFun.getProfileImage(images: places[0].userData?.images)]!);
    }
    return BitmapDescriptor.bytes(data.buffer.asUint8List());
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      CommonUI.snackBarWidget('$error');
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}

class Place with cluster.ClusterItem {
  final RegistrationUserData? userData;
  final LatLng latLng;

  Place({
    required this.userData,
    required this.latLng,
  });

  @override
  LatLng get location => latLng;
}
