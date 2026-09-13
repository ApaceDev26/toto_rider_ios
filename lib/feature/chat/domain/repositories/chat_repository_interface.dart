import 'package:toto_rider/api/api_client.dart';
import 'package:toto_rider/helper/user_type_helper.dart';
import 'package:toto_rider/interface/repository_interface.dart';

abstract class ChatRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getConversationList(int offset, String type);
  Future<dynamic> searchConversationList(String name);
  Future<dynamic> getMessages(
      int offset, int? userId, UserType userType, int? conversationID);
  Future<dynamic> sendMessage(String message, List<MultipartBody> file,
      int? conversationId, int? userId, UserType userType);
}
