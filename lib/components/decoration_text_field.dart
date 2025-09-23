import 'package:aqui_ajuda_app/common/colors.dart';
import 'package:flutter/material.dart';

InputDecoration getLoginInputDecoration(String label, IconData icon) {
  return InputDecoration(
    hintText: label,
    fillColor: MyColors.offWhite,
    filled: true,
    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(64)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: BorderSide(color: MyColors.pretoSuave, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: BorderSide(color: MyColors.azulClaro, width: 2),
    ),
    prefixIcon: Padding(padding: EdgeInsets.only(left: 15), child: Icon(icon)),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: BorderSide(color: MyColors.vermelhoSuave, width: 4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: BorderSide(color: MyColors.vermelhoSuave, width: 4),
    ),
  );
}
