import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/screen/get_started_screen/get_started_screen_view_model.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';

class Screen1 extends StatelessWidget {
  final VoidCallback onTap;
  final GetStartedScreenViewModel model;

  const Screen1({Key? key, required this.onTap, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      color: ColorRes.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(AssetRes.themeLabel,
              width: Get.width / 1.7, fit: BoxFit.cover),
          Positioned(bottom: 70, child: submitBtn()),
        ],
      ),
    );
  }

  Widget submitBtn() {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 238,
        decoration: BoxDecoration(
          color: ColorRes.darkOrange.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            S.current.continueText,
            style: const TextStyle(
              color: ColorRes.darkOrange,
              fontSize: 15,
              fontFamily: FontRes.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}
