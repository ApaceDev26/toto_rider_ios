import 'dart:convert';

import 'package:get/get.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_model.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_response_model.dart';
import 'package:toto_rider/feature/auth/domain/repositories/address_repository_interface.dart';
import 'package:toto_rider/feature/auth/domain/services/address_service_interface.dart';

class AddressService implements AddressServiceInterface {
  final AddressRepositoryInterface addressRepositoryInterface;
  AddressService({required this.addressRepositoryInterface});

  @override
  Future<List<ZoneModel>?> getZoneList() async {
    return await addressRepositoryInterface.getList();
  }

  @override
  Future<Response> getZone(String lat, String lng) async {
    return await addressRepositoryInterface.getZone(lat, lng);
  }

  @override
  Future<double?> getRoadDistanceKm(double originLat, double originLng, double destinationLat, double destinationLng) async {
    Response response = await addressRepositoryInterface.getRoadDistance(
      originLat.toString(),
      originLng.toString(),
      destinationLat.toString(),
      destinationLng.toString(),
    );

    try {
      if (response.statusCode == 200 && response.body['distanceMeters'] != null) {
        return (response.body['distanceMeters'] as num).toDouble() / 1000;
      }
    } catch (_) {}

    return null;
  }

  @override
  String? getUserAddress() {
    return addressRepositoryInterface.getUserAddress();
  }

  @override
  Future<bool> saveUserAddress(String address) async {
    return await addressRepositoryInterface.saveUserAddress(address);
  }

  @override
  int? setZoneIndex(
      int? selectedIndex, List<ZoneModel>? zoneList, List<int>? zoneIds) {
    int? selectedZoneIndex = selectedIndex;
    for (int index = 0; index < zoneList!.length; index++) {
      if (zoneIds!.contains(zoneList[index].id)) {
        selectedZoneIndex = index;
        break;
      }
    }
    return selectedZoneIndex;
  }

  @override
  List<int> prepareZoneIds(Response response) {
    List<int> zoneIds = [];
    jsonDecode(response.body['zone_id']).forEach((zoneId) {
      zoneIds.add(int.parse(zoneId.toString()));
    });
    return zoneIds;
  }

  @override
  List<ZoneData> prepareZoneData(Response response) {
    List<ZoneData> zoneData = [];
    response.body['zone_data']
        .forEach((zone) => zoneData.add(ZoneData.fromJson(zone)));
    return zoneData;
  }
}
