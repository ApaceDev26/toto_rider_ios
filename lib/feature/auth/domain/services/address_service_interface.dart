import 'package:get/get_connect/http/src/response/response.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_model.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_response_model.dart';

abstract class AddressServiceInterface {
  Future<dynamic> getZoneList();
  Future<dynamic> getZone(String lat, String lng);
  Future<double?> getRoadDistanceKm(double originLat, double originLng, double destinationLat, double destinationLng);
  String? getUserAddress();
  Future<bool> saveUserAddress(String address);
  int? setZoneIndex(
      int? selectedIndex, List<ZoneModel>? zoneList, List<int>? zoneIds);
  List<int> prepareZoneIds(Response response);
  List<ZoneData> prepareZoneData(Response response);
}
