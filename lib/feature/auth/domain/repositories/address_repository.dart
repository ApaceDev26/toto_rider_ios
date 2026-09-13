import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toto_rider/api/api_client.dart';
import 'package:toto_rider/feature/auth/domain/models/zone_model.dart';
import 'package:toto_rider/feature/auth/domain/repositories/address_repository_interface.dart';
import 'package:toto_rider/util/app_constants.dart';

class AddressRepository implements AddressRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AddressRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<ZoneModel>?> getList() async {
    List<ZoneModel>? zoneList;
    Response response = await apiClient.getData(AppConstants.zoneListUri);
    if (response.statusCode == 200) {
      zoneList = [];
      response.body.forEach((zone) => zoneList!.add(ZoneModel.fromJson(zone)));
    }
    return zoneList;
  }

  @override
  Future<Response> getZone(String lat, String lng) async {
    return await apiClient.getData('${AppConstants.zoneUri}?lat=$lat&lng=$lng');
  }

  @override
  Future<Response> getRoadDistance(String originLat, String originLng, String destinationLat, String destinationLng) async {
    return await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=$originLat&origin_lng=$originLng'
      '&destination_lat=$destinationLat&destination_lng=$destinationLng&mode=DRIVE',
    );
  }

  @override
  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  @override
  Future<bool> saveUserAddress(String address) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      sharedPreferences.getString(AppConstants.languageCode),
    );
    return await sharedPreferences.setString(AppConstants.userAddress, address);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
