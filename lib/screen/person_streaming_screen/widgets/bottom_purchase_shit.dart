import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/setting.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/utils/app_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/font_res.dart';

class BottomPurchaseShirt extends StatelessWidget {
  final List<Gifts>? giftList;
  final VoidCallback onAddDiamonds;
  final Function(Gifts? data) onGiftTap;
  final int? diamond;
  final RegistrationUserData? userData;

  const BottomPurchaseShirt(
      {Key? key,
      required this.giftList,
      required this.onAddDiamonds,
      required this.onGiftTap,
      required this.diamond,
      required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height / 2,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.mirror),
          child: Container(
            width: Get.width,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              color: ColorRes.black.withValues(alpha: 0.33),
            ),
            child: Column(
              children: [
                topButtons(),
                const SizedBox(height: 17),
                Expanded(
                  child: GridView.builder(
                    itemCount: giftList?.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (userData?.isFake != 1) {
                            giftList![index].coinPrice! <= (diamond ?? 0).toInt() ? onGiftTap(giftList?[index]) : () {};
                          } else {
                            if (Get.isBottomSheetOpen == true) {
                              Get.back();
                            }
                            CommonUI.snackBarWidget(S.of(context).youAreFakeUser);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorRes.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network('${ConstRes.aImageBaseUrl}${giftList?[index].image}',
                                    height: 45.5,
                                    width: 52.45,
                                    fit: BoxFit.cover,
                                    color: diamond == null || giftList![index].coinPrice! > diamond!.toInt()
                                        ? ColorRes.black.withValues(alpha: 0.2)
                                        : null),
                              ),
                              const SizedBox(height: 2.5),
                              Text(
                                "${giftList?[index].coinPrice} ${AppRes.coinIcon}",
                                style: TextStyle(
                                  color: diamond == null || giftList![index].coinPrice! > diamond!.toInt()
                                      ? ColorRes.black.withValues(alpha: 0.2)
                                      : ColorRes.white,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topButtons() {
    return Row(
      children: [
        InkWell(
          onTap: onAddDiamonds,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 35,
            width: 81,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorRes.lightOrange,
                  ColorRes.darkOrange,
                ],
              ),
            ),
            child: Center(
              child: Text(
                "${AppRes.coinIcon} ${NumberFormat.compact(locale: 'en').format(diamond ?? 0)}",
                style: const TextStyle(
                  color: ColorRes.white,
                  fontSize: 13,
                  fontFamily: FontRes.regular,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        InkWell(
          onTap: onAddDiamonds,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 35,
            width: 131,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorRes.lightOrange,
                  ColorRes.darkOrange,
                ],
              ),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: S.current.add,
                      style: const TextStyle(
                        color: ColorRes.white,
                        fontSize: 13,
                        fontFamily: FontRes.regular,
                      ),
                    ),
                    TextSpan(
                      text: " ${S.current.diamonds}",
                      style: const TextStyle(
                        color: ColorRes.white,
                        fontSize: 13,
                        fontFamily: FontRes.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
