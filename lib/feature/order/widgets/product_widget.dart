import 'package:toto_rider/common/widgets/custom_image_widget.dart';
import 'package:toto_rider/feature/order/domain/models/order_details_model.dart';
import 'package:toto_rider/helper/price_converter_helper.dart';
import 'package:toto_rider/util/dimensions.dart';
import 'package:toto_rider/util/styles.dart';
import 'package:flutter/material.dart';

class ProductWidget extends StatelessWidget {
  final OrderDetailsModel orderDetailsModel;
  const ProductWidget({super.key, required this.orderDetailsModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(
              image: '${orderDetailsModel.foodDetails!.imageFullUrl}',
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text('✕ ${orderDetailsModel.quantity}'),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
            child: Text(
          orderDetailsModel.foodDetails!.name!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        )),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(
          PriceConverter.convertPrice(
              orderDetailsModel.price! - orderDetailsModel.discountOnFood!),
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
      ]),
    );
  }
}
