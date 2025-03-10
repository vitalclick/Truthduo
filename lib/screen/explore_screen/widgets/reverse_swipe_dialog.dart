import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';

class ReverseSwipeDialog extends StatefulWidget {
  final Function(bool isSelected) onContinueTap;
  final VoidCallback? onCancelTap;
  final int? walletCoin;
  final String title1;
  final String title2;
  final String dialogDisc;
  final String coinPrice;
  final bool isCheckBoxVisible;

  const ReverseSwipeDialog(
      {Key? key,
      this.onCancelTap,
      required this.onContinueTap,
      required this.walletCoin,
      required this.title1,
      required this.title2,
      required this.dialogDisc,
      required this.coinPrice,
      required this.isCheckBoxVisible})
      : super(key: key);

  @override
  State<ReverseSwipeDialog> createState() => _ReverseSwipeDialogState();
}

class _ReverseSwipeDialogState extends State<ReverseSwipeDialog> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
      child: Dialog(
        backgroundColor: ColorRes.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 60),
        child: AspectRatio(
          aspectRatio: 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: ColorRes.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Spacer(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.title1,
                        style: const TextStyle(
                          color: ColorRes.black,
                          fontSize: 20,
                          fontFamily: FontRes.regular,
                        ),
                      ),
                      TextSpan(
                        text: " ${widget.title2}",
                        style: const TextStyle(
                          color: ColorRes.black,
                          fontSize: 20,
                          fontFamily: FontRes.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AssetRes.diamond, height: 30, width: 30),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.coinPrice,
                      style: const TextStyle(color: ColorRes.darkGrey9, fontFamily: FontRes.semiBold, fontSize: 30),
                    )
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: Get.width / 2,
                  child: Text(
                    widget.dialogDisc,
                    style: const TextStyle(color: ColorRes.darkGrey9, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  color: ColorRes.grey10,
                  height: 50,
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: S.current.walletCap,
                          style: const TextStyle(
                            color: ColorRes.darkGrey9,
                            fontSize: 16,
                            fontFamily: FontRes.regular,
                          ),
                        ),
                        TextSpan(
                          text: " : ${widget.walletCoin}",
                          style: const TextStyle(
                              color: ColorRes.darkGrey9, fontSize: 16, fontFamily: FontRes.semiBold, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: widget.isCheckBoxVisible,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          isSelected = !isSelected;
                          setState(() {});
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: !isSelected
                                ? Border.all(
                                    color: ColorRes.darkOrange,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(5),
                            gradient: isSelected
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      ColorRes.lightOrange,
                                      ColorRes.darkOrange,
                                    ],
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isSelected ? Icons.check : null,
                            color: ColorRes.white,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        S.current.useAutomaticallyEtc,
                        style: const TextStyle(color: ColorRes.grey),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.onContinueTap(isSelected);
                  },
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorRes.lightOrange,
                            ColorRes.darkOrange,
                          ],
                        )),
                    child: Text(
                      S.current.continueText,
                      style: const TextStyle(color: ColorRes.white, fontFamily: FontRes.bold, fontSize: 15),
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onCancelTap ??
                      () {
                        Get.back();
                      },
                  child: Text(
                    S.current.cancel,
                    style: const TextStyle(color: ColorRes.darkGrey9, fontFamily: FontRes.regular, fontSize: 15),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyWalletDialog extends StatelessWidget {
  final VoidCallback onContinueTap;
  final VoidCallback onCancelTap;
  final int? walletCoin;

  const EmptyWalletDialog({Key? key, this.walletCoin, required this.onContinueTap, required this.onCancelTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
      child: Dialog(
        backgroundColor: ColorRes.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 60),
        child: AspectRatio(
          aspectRatio: 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: ColorRes.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Spacer(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: S.current.empty,
                        style: const TextStyle(
                          color: ColorRes.black,
                          fontSize: 20,
                          fontFamily: FontRes.regular,
                        ),
                      ),
                      TextSpan(
                        text: " ${S.current.walletCap}",
                        style: const TextStyle(
                          color: ColorRes.black,
                          fontSize: 20,
                          fontFamily: FontRes.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Image.asset(AssetRes.emptyEmoji, height: 50, width: 50),
                const Spacer(),
                SizedBox(
                  width: Get.width / 2,
                  child: Text(
                    S.current.itLooksLikeEtc,
                    style: const TextStyle(color: ColorRes.darkGrey9, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  color: ColorRes.grey10,
                  height: 50,
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: S.current.walletCap,
                          style: const TextStyle(
                            color: ColorRes.darkGrey9,
                            fontSize: 16,
                            fontFamily: FontRes.regular,
                          ),
                        ),
                        TextSpan(
                          text: " : $walletCoin",
                          style: const TextStyle(
                              color: ColorRes.darkGrey9, fontSize: 16, fontFamily: FontRes.semiBold, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onContinueTap,
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorRes.lightOrange,
                            ColorRes.darkOrange,
                          ],
                        )),
                    child: Text(
                      S.current.continueCap,
                      style: const TextStyle(color: ColorRes.white, fontFamily: FontRes.bold, fontSize: 15),
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCancelTap,
                  child: Text(
                    S.current.cancelCap,
                    style: const TextStyle(color: ColorRes.darkGrey9, fontFamily: FontRes.regular, fontSize: 15),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
