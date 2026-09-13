import 'package:get/get.dart';
import 'package:toto_rider/interface/repository_interface.dart';

abstract class AddressRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getZone(String lat, String lng);
  Future<Response> getRoadDistance(String originLat, String originLng, String destinationLat, String destinationLng);
  String? getUserAddress();
  Future<bool> saveUserAddress(String address);
}
