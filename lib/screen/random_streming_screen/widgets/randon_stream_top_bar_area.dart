import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/chat_and_live_stream/live_stream.dart';
import 'package:orange_ui/utils/app_res.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';

class RandomStreamTopBarArea extends StatelessWidget {
  final VoidCallback onEndBtnTap;
  final VoidCallback onDiamondTap;
  final VoidCallback onCameraTap;
  final VoidCallback onSpeakerTap;
  final bool mute;
  final LiveStreamUser? user;

  const RandomStreamTopBarArea(
      {Key? key,
      required this.onEndBtnTap,
      required this.onDiamondTap,
      required this.onCameraTap,
      required this.onSpeakerTap,
      required this.mute,
      this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 45,
            width: Get.width,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: ColorRes.black.withValues(alpha: 0.33),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Center(
                      child: Image.asset(
                        AssetRes.themeLabelWhite,
                        height: 20,
                        width: 69,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      S.current.live,
                      style: const TextStyle(
                        color: ColorRes.white,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onEndBtnTap,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 88,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ColorRes.darkOrange,
                              ColorRes.lightOrange,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            S.current.end,
                            style: const TextStyle(
                              color: ColorRes.white,
                              fontSize: 12,
                              fontFamily: FontRes.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "${NumberFormat.compact(locale: 'en').format(double.parse('${user?.watchingCount ?? '0'}'))} ${S.current.viewers}",
                    style: const TextStyle(
                      color: ColorRes.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onDiamondTap,
            child: Container(
              height: 45,
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: ColorRes.black.withValues(alpha: 0.33),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    "${AppRes.coinIcon} ${NumberFormat.compact(locale: 'en').format(double.parse('${user?.collectedDiamond ?? '0'}'))} ${S.current.collected}",
                    style: const TextStyle(
                      color: ColorRes.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(37),
                    onTap: onCameraTap,
                    child: Container(
                      height: 37,
                      width: 37,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorRes.black.withValues(alpha: 0.33),
                      ),
                      child: Center(
                        child: Image.asset(
                          AssetRes.camera2,
                          height: 15,
                          width: 15,
                          color: ColorRes.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(37),
                    onTap: onSpeakerTap,
                    child: Container(
                      height: 37,
                      width: 37,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorRes.black.withValues(alpha: 0.33),
                      ),
                      child: Center(
                        child: Image.asset(
                          !mute ? AssetRes.speaker : AssetRes.speakerOff,
                          color: ColorRes.white,
                          height: 15,
                          width: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
