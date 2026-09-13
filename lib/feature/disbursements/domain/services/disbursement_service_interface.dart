import 'package:flutter/material.dart';
import 'package:toto_rider/common/widgets/custom_dropdown_widget.dart';
import 'package:toto_rider/feature/disbursements/domain/models/withdraw_method_model.dart';

abstract class DisbursementServiceInterface {
  Future<dynamic> addWithdraw(Map<String?, String> data);
  Future<dynamic> getDisbursementMethodList();
  Future<dynamic> makeDefaultMethod(Map<String?, String> data);
  Future<dynamic> deleteMethod(int id);
  Future<dynamic> getDisbursementReport(int offset);
  Future<dynamic> getWithdrawMethodList();
  List<DropdownItem<int>> processMethodList(
      List<WidthDrawMethodModel>? widthDrawMethods);
  List<MethodFields> generateMethodFields(
      List<WidthDrawMethodModel>? widthDrawMethods, int? selectedMethodIndex);
  List<TextEditingController> generateTextControllerList(
      List<WidthDrawMethodModel>? widthDrawMethods, int? selectedMethodIndex);
  List<FocusNode> generateFocusList(
      List<WidthDrawMethodModel>? widthDrawMethods, int? selectedMethodIndex);
}
