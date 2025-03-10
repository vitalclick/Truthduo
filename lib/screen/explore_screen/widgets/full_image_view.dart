import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/common/full_image_view_shimmer.dart';
import 'package:orange_ui/common/profile_detail_card.dart';
import 'package:orange_ui/common/social_icon.dart';
import 'package:orange_ui/common/top_story_line.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/explore_screen/explore_screen_view_model.dart';
import 'package:orange_ui/screen/explore_screen/widgets/suggest_photo_tap_view.dart';
import 'package:orange_ui/screen/explore_screen/widgets/swipe_right_view.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';

class FullImageView extends StatelessWidget {
  final ExploreScreenViewModel model;

  const FullImageView({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.isLoading && model.userList.isEmpty) {
      return const FullImageViewShimmer();
    } else {
      return Expanded(
          child: model.userList.isEmpty
              ? CommonUI.noData()
              : CardSwiper(
                  controller: model.cardController,
                  cardsCount: model.userList.length,
                  onUndo: model.onUndo,
                  onSwipe: model.onSwipe,
                  isDisabled: model.isSwipeDisable,
                  numberOfCardsDisplayed: model.userList.length > 1 ? 2 : 1,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                  cardBuilder: (context, currentProfileIndex, percentThresholdX, percentThresholdY) {
                    RegistrationUserData userData = model.userList[currentProfileIndex];
                    final PageController pageController = PageController(initialPage: 0);

                    return Stack(
                      children: [
                        ImagePageView(userData: userData, pageController: pageController, model: model),
                        Column(
                          children: [
                            const SizedBox(height: 14),
                            TopStoryLine(pageController: pageController, imageLength: userData.images.length),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9),
                              child: Row(
                                children: [
                                  SocialIcon(
                                      icon: AssetRes.instagramLogo,
                                      onSocialIconTap: () => model.onSocialBtnTap(2),
                                      isVisible: model.isSocialBtnVisible(userData.instagram)),
                                  SocialIcon(
                                      icon: AssetRes.facebookLogo,
                                      onSocialIconTap: () => model.onSocialBtnTap(1),
                                      isVisible: model.isSocialBtnVisible(userData.facebook)),
                                  SocialIcon(
                                      icon: AssetRes.youtubeLogo,
                                      onSocialIconTap: () => model.onSocialBtnTap(0),
                                      isVisible: model.isSocialBtnVisible(userData.youtube)),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            ProfileDetailCard(userData: userData, onImageTap: model.onImageTap)
                          ],
                        ),
                        if (model.likeStatus != 0)
                          Positioned(
                            top: 50,
                            left: model.isLikeDisLikeStatus ? 50 : null,
                            right: model.isLikeDisLikeStatus ? null : 50,
                            child: RotationTransition(
                              turns: AlwaysStoppedAnimation(!model.isLikeDisLikeStatus ? -15.9 : 15.9),
                              child: Image.asset(
                                model.isLikeDisLikeStatus == false ? AssetRes.icNope : AssetRes.icLike,
                                width: 150,
                                height: 150,
                              ),
                            ),
                          ),
                        SwipeRightView(model: model, index: currentProfileIndex),
                        SuggestPhotoTapView(model: model, index: currentProfileIndex)
                      ],
                    );
                  },
                ));
    }
  }
}

class BorderLineCustom extends StatelessWidget {
  const BorderLineCustom({Key? key, this.height = 10, this.color = Colors.black}) : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 1.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (5 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class ImagePageView extends StatefulWidget {
  final RegistrationUserData userData;
  final PageController pageController;
  final ExploreScreenViewModel model;

  const ImagePageView({Key? key, required this.userData, required this.pageController, required this.model})
      : super(key: key);

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  @override
  Widget build(BuildContext context) {
    return widget.userData.images.isEmpty
        ? CommonUI.profileImagePlaceHolder(
            name: widget.userData.fullname,
            heightWidth: MediaQuery.of(context).size.height,
            borderRadius: 20,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: widget.pageController,
              itemCount: widget.userData.images.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, currentImageIndex) {
                return Stack(
                  children: [
                    CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        color: ColorRes.dimGrey7,
                        child: Image.asset(AssetRes.placeholder),
                      ),
                      imageUrl: CommonFun.getProfileImage(
                        images: widget.userData.images,
                        index: currentImageIndex,
                      ),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      errorWidget: (context, error, stackTrace) {
                        return CommonUI.profileImagePlaceHolder(
                            name: widget.userData.fullname,
                            heightWidth: MediaQuery.of(context).size.height,
                            borderRadius: 20);
                      },
                      fadeInDuration: const Duration(milliseconds: 100),
                      fadeOutDuration: const Duration(milliseconds: 100),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.model.onImageLeftTap(widget.pageController, currentImageIndex),
                            child: Container(height: Get.height - 256, color: ColorRes.transparent),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.model.onImageRightTap(
                                widget.pageController, currentImageIndex, widget.userData.images.length),
                            child: Container(height: Get.height - 256, color: ColorRes.transparent),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          );
  }
}
