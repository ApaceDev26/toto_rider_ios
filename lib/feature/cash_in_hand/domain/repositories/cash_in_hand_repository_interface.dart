import 'package:toto_rider/interface/repository_interface.dart';

abstract class CashInHandRepositoryInterface implements RepositoryInterface {
  Future<dynamic> makeCollectCashPayment(
      double amount, String paymentGatewayName);
  Future<dynamic> makeWalletAdjustment();
}
