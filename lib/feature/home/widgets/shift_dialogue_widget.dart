import 'package:toto_rider/feature/profile/controllers/profile_controller.dart';
import 'package:toto_rider/helper/date_converter_helper.dart';
import 'package:toto_rider/util/dimensions.dart';
import 'package:toto_rider/util/styles.dart';
import 'package:toto_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShiftDialogueWidget extends StatefulWidget {
  const ShiftDialogueWidget({super.key});

  @override
  State<ShiftDialogueWidget> createState() => _ShiftDialogueWidgetState();
}

class _ShiftDialogueWidgetState extends State<ShiftDialogueWidget> {
  @override
  void initState() {
    super.initState();

    Get.find<ProfileController>().initData();
  }

  void _closeDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<void> _submitShift({int? shiftId}) async {
    final profileController = Get.find<ProfileController>();
    final success = await profileController.updateActiveStatus(
      shiftId: shiftId,
      popAfterSuccess: false,
    );
    if (success) {
      _closeDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeDialog();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: GetBuilder<ProfileController>(builder: (profileController) {
          return SizedBox(
            width: 500,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(children: [
              Container(
                width: 500,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 5)
                  ],
                ),
                child: Row(children: [
                  IconButton(
                    onPressed: profileController.shiftLoading ? null : _closeDialog,
                    icon: Icon(Icons.close,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  Expanded(
                    child: Text(
                      'select_shift'.tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                  const SizedBox(width: 48),
                ]),
              ),
              Expanded(
                child: profileController.shifts != null
                    ? profileController.shifts!.isNotEmpty
                        ? ListView.builder(
                            itemCount: profileController.shifts!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall),
                                child: ListTile(
                                  onTap: () {
                                    profileController.setShiftId(
                                        profileController.shifts![index].id);
                                  },
                                  title: Row(children: [
                                    Icon(
                                        profileController.shifts![index].id ==
                                                profileController.shiftId
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: Theme.of(context).primaryColor,
                                        size: 18),
                                    const SizedBox(
                                        width:
                                            Dimensions.paddingSizeExtraSmall),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              profileController
                                                  .shifts![index].name!,
                                              style: robotoMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          Text(
                                            '${DateConverter.onlyTimeShow(profileController.shifts![index].startTime!)} - ${DateConverter.onlyTimeShow(profileController.shifts![index].endTime!)}',
                                            style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                          ),
                                        ]),
                                  ]),
                                ),
                              );
                            },
                          )
                        : Center(child: Text('no_reasons_available'.tr))
                    : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.fontSizeDefault,
                    vertical: Dimensions.paddingSizeSmall),
                child: !profileController.shiftLoading
                    ? Row(children: [
                        Expanded(
                            child: CustomButtonWidget(
                          buttonText: 'skip'.tr,
                          backgroundColor: Theme.of(context).disabledColor,
                          radius: 50,
                          onPressed: () => _submitShift(),
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                            child: CustomButtonWidget(
                          buttonText: 'submit'.tr,
                          radius: 50,
                          onPressed: () =>
                              _submitShift(shiftId: profileController.shiftId),
                        )),
                      ])
                    : const Center(child: CircularProgressIndicator()),
              ),
            ]),
          );
        }),
      ),
    );
  }
}
