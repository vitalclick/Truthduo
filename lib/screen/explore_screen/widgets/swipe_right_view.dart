import 'package:flutter/material.dart';
import 'package:orange_ui/screen/explore_screen/explore_screen_view_model.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';

class SwipeRightView extends StatelessWidget {
  final ExploreScreenViewModel model;
  final int index;

  const SwipeRightView({Key? key, required this.model, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (model.currentProfileIndex == index && model.suggestSwipeStatus == 0)
        ? GestureDetector(
            onTap: model.onTapSwipeView,
            onHorizontalDragEnd: (details) {
              model.onTapSwipeView();
            },
            onVerticalDragEnd: (details) {
              model.onTapSwipeView();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: ColorRes.black.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetRes.icSwipeRight,
                    height: 50,
                    width: 50,
                    color: ColorRes.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'SWIPE RIGHT',
                    style: TextStyle(color: ColorRes.white, fontFamily: FontRes.medium, letterSpacing: 1, fontSize: 18),
                  )
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}
