import 'package:toto_rider/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:toto_rider/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:toto_rider/common/widgets/custom_image_widget.dart';
import 'package:toto_rider/feature/auth/controllers/address_controller.dart';
import 'package:toto_rider/feature/order/controllers/order_controller.dart';
import 'package:toto_rider/feature/order/screens/order_details_screen.dart';
import 'package:toto_rider/feature/order/screens/order_location_screen.dart';
import 'package:toto_rider/feature/splash/controllers/splash_controller.dart';
import 'package:toto_rider/feature/order/domain/models/order_model.dart';
import 'package:toto_rider/feature/profile/controllers/profile_controller.dart';
import 'package:toto_rider/helper/date_converter_helper.dart';
import 'package:toto_rider/helper/price_converter_helper.dart';
import 'package:toto_rider/helper/route_helper.dart';
import 'package:toto_rider/util/dimensions.dart';
import 'package:toto_rider/util/images.dart';
import 'package:toto_rider/util/styles.dart';
import 'package:toto_rider/common/widgets/custom_button_widget.dart';
import 'package:toto_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderRequestWidget extends StatefulWidget {
  final OrderModel orderModel;
  final int index;
  final bool fromDetailsPage;
  final Function onTap;
  const OrderRequestWidget(
      {super.key,
      required this.orderModel,
      required this.index,
      required this.onTap,
      this.fromDetailsPage = false});

  @override
  State<OrderRequestWidget> createState() => _OrderRequestWidgetState();
}

class _OrderRequestWidgetState extends State<OrderRequestWidget> {
  double? _distance;
  int _distanceRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final requestId = ++_distanceRequestId;
    final restaurantLatLng = LatLng(
      double.parse(widget.orderModel.restaurantLat!),
      double.parse(widget.orderModel.restaurantLng!),
    );

    final distance = await Get.find<AddressController>()
        .getRoadDistanceToRider(restaurantLatLng);

    if (!mounted || requestId != _distanceRequestId) {
      return;
    }

    setState(() {
      _distance = distance;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_distance == null &&
        Get.find<AddressController>().getRiderLatLng() != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _distance == null) {
          _loadDistance();
        }
      });
    }

    final distance = _distance;

    return GetBuilder<ProfileController>(builder: (_) {
      return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            width: 1.5),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.2),
                        width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      image: widget.orderModel.restaurantLogoFullUrl ?? '',
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        widget.orderModel.restaurantName ??
                            'no_restaurant_data_found'.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        '${widget.orderModel.detailsCount} ${widget.orderModel.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        widget.orderModel.restaurantAddress ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor),
                      ),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    DateConverter.dateTimeStringToTime(widget.orderModel.createdAt!),
                    style: robotoMedium.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withValues(alpha: 0.7)),
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      DateConverter.getTimeDifference(widget.orderModel.createdAt!)
                          .split(' ')[0],
                      style: robotoMedium.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      DateConverter.getTimeDifference(widget.orderModel.createdAt!)
                          .split(' ')
                          .sublist(1)
                          .join(' '),
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall + 2),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Row(children: [
                      (Get.find<SplashController>()
                                  .configModel!
                                  .showDmEarning! &&
                              Get.find<ProfileController>()
                                      .profileModel!
                                      .earnings ==
                                  1)
                          ? Text(
                              PriceConverter.convertPrice(
                                  widget.orderModel.originalDeliveryCharge! +
                                      widget.orderModel.dmTips!),
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall),
                            )
                          : const SizedBox(),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        widget.orderModel.paymentMethod == 'cash_on_delivery'
                            ? 'cod'.tr
                            : 'digitally_paid'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                    ]),
                  ),
                ]),
              ]),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 1,
                  margin: const EdgeInsets.only(
                      left: Dimensions.paddingSizeLarge + 4),
                  child: ListView.builder(
                    itemCount: 4,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeExtraSmall),
                        height: 5,
                        width: 1,
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.5),
                      );
                    },
                  ),
                ),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.2),
                        width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      image: widget.orderModel.customer?.imageFullUrl ?? '',
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        'deliver_to'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        widget.orderModel.deliveryAddress?.address ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor),
                      ),
                    ])),
                InkWell(
                  onTap: () => Get.to(() => OrderLocationScreen(
                        orderModel: widget.orderModel,
                        orderController: orderController,
                        index: widget.index,
                        onTap: widget.onTap,
                      )),
                  child: Row(children: [
                    CustomAssetImageWidget(
                      image: Images.locationIcon,
                      height: 12,
                      width: 15,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'view_map'.tr,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            height: 80,
            decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(Dimensions.radiusDefault))),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            margin: const EdgeInsets.all(0.2),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'restaurant_is'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        distance == null
                            ? '--'
                            : '${distance > 1000 ? '1000+' : distance.toStringAsFixed(2)} ${'km_away_from_you'.tr}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                    ]),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                flex: 3,
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        showCustomBottomSheet(
                          child: CustomConfirmationBottomSheet(
                            title: 'ignore_this_order'.tr,
                            description:
                                'are_you_sure_want_to_ignore_this_order'.tr,
                            confirmButtonText: 'ignore'.tr,
                            onConfirm: () {
                              orderController.ignoreOrder(widget.index);
                              Get.back();
                              showCustomSnackBar('order_ignored'.tr,
                                  isError: false);
                            },
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(1170, 45),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          side: BorderSide(
                              width: 1, color: Theme.of(context).hintColor),
                        ),
                      ),
                      child: Text('ignore'.tr,
                          textAlign: TextAlign.center,
                          style: robotoBold.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: Dimensions.fontSizeLarge,
                          )),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall + 2),
                  Expanded(
                    child: CustomButtonWidget(
                      height: 45,
                      radius: Dimensions.radiusDefault,
                      buttonText: 'accept'.tr,
                      onPressed: () {
                        showCustomBottomSheet(
                          child: CustomConfirmationBottomSheet(
                            title: 'accept_this_order'.tr,
                            description:
                                'make_sure_your_availability_to_deliver_this_order_on_time_before_accept'
                                    .tr,
                            onConfirm: () {
                              orderController
                                  .acceptOrder(widget.orderModel.id, widget.index, widget.orderModel)
                                  .then((isSuccess) {
                                if (isSuccess) {
                                  widget.onTap();
                                  widget.orderModel.orderStatus =
                                      (widget.orderModel.orderStatus == 'pending' ||
                                              widget.orderModel.orderStatus ==
                                                  'confirmed')
                                          ? 'accepted'
                                          : widget.orderModel.orderStatus;
                                  Get.back();
                                  Get.toNamed(
                                    RouteHelper.getOrderDetailsRoute(
                                        widget.orderModel.id),
                                    arguments: OrderDetailsScreen(
                                      orderId: widget.orderModel.id,
                                      isRunningOrder: true,
                                      orderIndex: orderController
                                              .currentOrderList!.length -
                                          1,
                                    ),
                                  );
                                } else {
                                  orderController.getLatestOrders();
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]);
      }),
    );
    });
  }
}
