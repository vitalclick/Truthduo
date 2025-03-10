import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/common/profile_detail_card.dart';
import 'package:orange_ui/common/social_icon.dart';
import 'package:orange_ui/common/top_story_line.dart';
import 'package:orange_ui/screen/randoms_search_screen/randoms_search_screen_view_model.dart';
import 'package:orange_ui/screen/shimmer_screen/shimmer_screen.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';

class ProfilePicArea extends StatelessWidget {
  final String profileImage;
  final RandomsSearchScreenViewModel model;

  const ProfilePicArea({Key? key, required this.profileImage, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: model.isLoading
          ? Container(
              width: Get.width,
              height: Get.height / 2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(AssetRes.worldMap),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SpinKitRipple(
                    borderWidth: 100,
                    duration: const Duration(milliseconds: 1500),
                    size: Get.width / 1.1,
                    itemBuilder: (BuildContext context, int index) {
                      return CircleAvatar(backgroundColor: ColorRes.grey21.withValues(alpha: 0.40));
                    },
                  ),
                  SpinKitRipple(
                    borderWidth: 50,
                    duration: const Duration(milliseconds: 1500),
                    size: Get.width / 1.5,
                    itemBuilder: (BuildContext context, int index) {
                      return CircleAvatar(
                        backgroundColor: ColorRes.grey21.withValues(alpha: 0.30),
                      );
                    },
                  ),
                  ClipOval(
                    child: Image.network(profileImage, height: Get.width / 3, width: Get.width / 3, fit: BoxFit.cover),
                  ),
                ],
              ))
          : model.userData == null
              ? CommonUI.noData()
              : Container(
                  width: Get.width / 1.2,
                  height: Get.height / 1.6,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: model.userData?.images == null || model.userData!.images.isEmpty
                            ? Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: ColorRes.darkOrange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20)),
                                  ),
                                  Center(
                                    child: Container(
                                        width: Get.width - 100,
                                        height: Get.height - 256,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorRes.darkOrange.withValues(alpha: 0.2),
                                        ),
                                        child: Image.asset(AssetRes.themeLabel)),
                                  ),
                                ],
                              )
                            : PageView.builder(
                                controller: model.pageController,
                                itemCount: model.userData?.images.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return FractionallySizedBox(
                                    widthFactor: 1 / model.pageController.viewportFraction,
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: CommonFun.getProfileImage(images: model.userData?.images),
                                          cacheKey: CommonFun.getProfileImage(images: model.userData?.images),
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height - 256,
                                          errorWidget: (context, error, stackTrace) {
                                            return CommonUI.profileImagePlaceHolder(
                                                name: model.userData?.fullname,
                                                heightWidth: MediaQuery.of(context).size.height - 256,
                                                borderRadius: 20);
                                          },
                                          progressIndicatorBuilder: (context, child, loadingProgress) {
                                            return ShimmerScreen.rectangular(
                                              width: Get.width,
                                              height: Get.height - 256,
                                              shapeBorder: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(21),
                                              ),
                                            );
                                          },
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: model.onLeftBtnClick,
                                                child: Container(height: Get.height - 256, color: ColorRes.transparent),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: model.onRightBtnClick,
                                                child: Container(height: Get.height - 256, color: ColorRes.transparent),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(
                        height: Get.height - 256,
                        width: Get.width,
                        child: Column(
                          children: [
                            const SizedBox(height: 14),
                            TopStoryLine(
                                pageController: model.pageController,
                                imageLength: (model.userData?.images ?? []).length),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 9),
                              child: Row(
                                children: [
                                  SocialIcon(
                                      icon: AssetRes.instagramLogo,
                                      onSocialIconTap: model.onInstagramTap,
                                      isVisible: model.isSocialBtnVisible(model.userData?.instagram)),
                                  SocialIcon(
                                      icon: AssetRes.facebookLogo,
                                      onSocialIconTap: model.onFBTap,
                                      isVisible: model.isSocialBtnVisible(model.userData?.facebook)),
                                  SocialIcon(
                                      icon: AssetRes.youtubeLogo,
                                      onSocialIconTap: model.onYoutubeTap,
                                      isVisible: model.isSocialBtnVisible(model.userData?.youtube)),
                                ],
                              ),
                            ),
                            ProfileDetailCard(onImageTap: model.onImageTap, userData: model.userData)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
