import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toto_rider/feature/auth/domain/services/address_service_interface.dart';
import 'package:toto_rider/feature/profile/controllers/profile_controller.dart';
import 'package:toto_rider/feature/splash/controllers/splash_controller.dart';
import 'package:toto_rider/feature/auth/domain/models/address_model.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_model.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_response_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressController extends GetxController implements GetxService {
  final AddressServiceInterface addressServiceInterface;
  AddressController({required this.addressServiceInterface});

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  XFile? _pickedCover;
  XFile? get pickedCover => _pickedCover;

  List<ZoneModel>? _zoneList;
  List<ZoneModel>? get zoneList => _zoneList;

  int? _selectedZoneIndex = 0;
  int? get selectedZoneIndex => _selectedZoneIndex;

  LatLng? _restaurantLocation;
  LatLng? get restaurantLocation => _restaurantLocation;

  List<int>? _zoneIds;
  List<int>? get zoneIds => _zoneIds;

  bool _inZone = false;
  bool get inZone => _inZone;

  int _zoneID = 0;
  int get zoneID => _zoneID;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _loading = false;
  bool get loading => _loading;

  // RecordLocationBody? _recordLocation;
  // RecordLocationBody? get recordLocationBody => _recordLocation;

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = 0;
    _restaurantLocation = null;
    _zoneIds = null;
    List<ZoneModel>? zoneList = await addressServiceInterface.getZoneList();
    if (zoneList != null) {
      _zoneList = [];
      _zoneList!.addAll(zoneList);
      _setLocation(LatLng(
        double.parse(
            Get.find<SplashController>().configModel!.defaultLocation!.lat ??
                '0'),
        double.parse(
            Get.find<SplashController>().configModel!.defaultLocation!.lng ??
                '0'),
      ));
    }
    update();
  }

  void _setLocation(LatLng location) async {
    ZoneResponseModel response = await getZone(
      location.latitude.toString(),
      location.longitude.toString(),
      false,
    );
    if (response.isSuccess && response.zoneIds.isNotEmpty) {
      _restaurantLocation = location;
      _zoneIds = response.zoneIds;
      _selectedZoneIndex = addressServiceInterface.setZoneIndex(
          _selectedZoneIndex, _zoneList, _zoneIds);
    } else {
      _restaurantLocation = null;
      _zoneIds = null;
    }
    update();
  }

  Future<ZoneResponseModel> getZone(String lat, String long, bool markerLoad,
      {bool updateInAddress = false}) async {
    if (markerLoad) {
      _loading = true;
    } else {
      _isLoading = true;
    }
    if (!updateInAddress) {
      update();
    }
    ZoneResponseModel responseModel;
    Response response = await addressServiceInterface.getZone(lat, long);
    if (response.statusCode == 200) {
      _inZone = true;
      _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
      List<int> zoneIds = addressServiceInterface.prepareZoneIds(response);
      List<ZoneData> zoneData =
          addressServiceInterface.prepareZoneData(response);
      responseModel = ZoneResponseModel(true, '', zoneIds, zoneData);
      if (updateInAddress) {
        AddressModel address = _getUserAddress()!;
        address.zoneData = zoneData;
        _saveUserAddress(address);
      }
    } else {
      _inZone = false;
      responseModel = ZoneResponseModel(false, response.statusText, [], []);
    }
    if (markerLoad) {
      _loading = false;
    } else {
      _isLoading = false;
    }
    update();
    return responseModel;
  }

  AddressModel? _getUserAddress() {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(addressServiceInterface.getUserAddress()!));
    } catch (e) {
      debugPrint('Not save address yet : $e');
    }
    return addressModel;
  }

  Future<bool> _saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await addressServiceInterface.saveUserAddress(userAddress);
  }

  bool isValidLatLng(LatLng latLng) {
    return latLng.latitude.abs() > 0.0001 && latLng.longitude.abs() > 0.0001;
  }

  LatLng? getRiderLatLng() {
    final location = Get.find<ProfileController>().recordLocationBody;
    if (location?.latitude == null || location?.longitude == null) {
      return null;
    }

    final latLng = LatLng(location!.latitude!, location.longitude!);
    return isValidLatLng(latLng) ? latLng : null;
  }

  double getStraightLineDistanceKm(LatLng storeLatLng, {LatLng? customerLatLng}) {
    double distance = 0;
    distance = Geolocator.distanceBetween(
            storeLatLng.latitude,
            storeLatLng.longitude,
            customerLatLng?.latitude ??
                Get.find<ProfileController>().recordLocationBody?.latitude ??
                0,
            customerLatLng?.longitude ??
                Get.find<ProfileController>().recordLocationBody?.longitude ??
                0) /
        1000;
    return distance;
  }

  Future<double?> getRoadDistanceKm(LatLng origin, LatLng destination) async {
    if (!isValidLatLng(origin) || !isValidLatLng(destination)) {
      return null;
    }

    final roadDistance = await addressServiceInterface.getRoadDistanceKm(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    if (roadDistance != null && roadDistance >= 0) {
      return roadDistance;
    }

    return getStraightLineDistanceKm(origin, customerLatLng: destination);
  }

  Future<double?> getRoadDistanceToRider(
    LatLng restaurantLatLng, {
    int maxAttempts = 15,
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final riderLatLng = getRiderLatLng();
      if (riderLatLng != null) {
        return getRoadDistanceKm(restaurantLatLng, riderLatLng);
      }

      if (attempt < maxAttempts - 1) {
        await Future.delayed(interval);
      }
    }

    return null;
  }

  double getRestaurantDistance(LatLng storeLatLng, {LatLng? customerLatLng}) {
    return getStraightLineDistanceKm(storeLatLng, customerLatLng: customerLatLng);
  }

  void setZoneIndex(int? index) {
    _selectedZoneIndex = index;
    update();
  }
}
