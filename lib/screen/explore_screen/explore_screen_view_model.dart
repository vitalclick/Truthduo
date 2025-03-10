import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/setting.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/bottom_diamond_shop/bottom_diamond_shop.dart';
import 'package:orange_ui/screen/live_grid_screen/live_grid_screen.dart';
import 'package:orange_ui/screen/map_screen/map_screen.dart';
import 'package:orange_ui/screen/notification_screen/notification_screen.dart';
import 'package:orange_ui/screen/search_screen/search_screen.dart';
import 'package:orange_ui/screen/user_detail_screen/user_detail_screen.dart';
import 'package:orange_ui/service/pref_service.dart';
import 'package:orange_ui/utils/app_res.dart';
import 'package:orange_ui/utils/pref_res.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/reverse_swipe_dialog.dart';

class ExploreScreenViewModel extends BaseViewModel {
  bool isLoading = false;
  List<RegistrationUserData> userList = [];
  int walletCoin = 0;
  RegistrationUserData? userData;
  bool isCheckboxSelected = false;
  InterstitialAd? interstitialAd;
  int count = 0;
  int suggestSwipeStatus = 0;
  int suggestPhotoTapStatus = 0;
  bool isSwipeDisable = true;
  int currentProfileIndex = 0;
  Appdata? settingAppData;
  int likeStatus = 0;
  CardSwiperController cardController = CardSwiperController();
  bool isLikeDisLikeStatus = false;

  void init() {
    initialCalling();
  }

  void initialCalling() {
    prefSetting();
    exploreScreenApiCall();
    getProfileAPi();
  }

  void prefSetting() async {
    PrefService.getSettingData().then((value) {
      settingAppData = value?.appdata;
      initInterstitialAds();
      notifyListeners();
    });
    suggestSwipeStatus = await PrefService.getInt(PrefConst.suggestSwipe) ?? 0;
    suggestPhotoTapStatus = await PrefService.getInt(PrefConst.suggestPhotoTap) ?? 0;
    if (suggestSwipeStatus == 1 && suggestPhotoTapStatus == 1) {
      isSwipeDisable = false;
      notifyListeners();
    }
  }

  Future<void> exploreScreenApiCall() async {
    if (userList.isEmpty) {
      isLoading = true;
    }
    ApiProvider().getExplorePageProfileList().then((value) async {
      userList.addAll(value.data ?? []);
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> getProfileAPi() async {
    ApiProvider().getProfile(userID: PrefService.userId).then((value) async {
      userData = value?.data;
      walletCoin = value?.data?.wallet ?? 0;
      isCheckboxSelected = await PrefService.getDialog(PrefConst.isDialogDialog) ?? false;
      notifyListeners();
    });
  }

  bool isSocialBtnVisible(String? socialLink) {
    if (socialLink != null) {
      return socialLink.contains(AppRes.isHttp) || socialLink.contains(AppRes.isHttps);
    } else {
      return false;
    }
  }

  Future<void> minusCoinApi() async {
    walletCoin -= (settingAppData?.reverseSwipePrice ?? 0);
    await ApiProvider().minusCoinFromWallet(settingAppData?.reverseSwipePrice).then((value) {
      if (value.status == false) {
        walletCoin += (settingAppData?.reverseSwipePrice ?? 0);
      }
    });
  }

  void _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
    )) {
      throw '${S.current.couldNotLaunch} ';
    }
  }

  void onSocialBtnTap(int type) {
    if (type == 0) {
      _launchUrl(userList[currentProfileIndex].youtube ?? '');
    } else if (type == 1) {
      _launchUrl(userList[currentProfileIndex].facebook ?? '');
    } else if (type == 2) {
      _launchUrl(userList[currentProfileIndex].instagram ?? '');
    }
  }

  void _suggestView() {
    if (suggestSwipeStatus == 0) {
      onTapSwipeView();
    } else if (suggestSwipeStatus == 1 && suggestPhotoTapStatus == 0) {
      onSuggestPhotoTap(true);
    } else if (suggestSwipeStatus == 1 && suggestPhotoTapStatus == 1) {
      isSwipeDisable = false;
      notifyListeners();
    }
  }

  void onReverseBtnTap() async {
    _suggestView();

    if (isSwipeDisable || userData == null) return;

    CommonFun.isBloc(
      userData,
      onCompletion: () async {
        if (currentProfileIndex == 0) return;

        // Handle swipe for non-fake users
        if (userData?.isFake != 1) {
          final reverseSwipePrice = settingAppData?.reverseSwipePrice ?? 0;

          if (reverseSwipePrice <= walletCoin && walletCoin != 0) {
            // Show reverse swipe dialog if checkbox is not selected
            if (!isCheckboxSelected) {
              await Get.dialog(ReverseSwipeDialog(
                  isCheckBoxVisible: true,
                  walletCoin: walletCoin,
                  title1: S.current.reverse,
                  title2: S.current.swipe,
                  dialogDisc: AppRes.reverseSwipeDisc(reverseSwipePrice),
                  coinPrice: '$reverseSwipePrice',
                  onContinueTap: (isSelected) {
                    Get.back();
                    PrefService.setDialog(PrefConst.isDialogDialog, isSelected);
                    cardController.undo();
                    minusCoinApi();
                  }));
              getProfileAPi();
            } else {
              cardController.undo();
              minusCoinApi();
            }
          } else {
            // Show empty wallet dialog when user doesn't have enough coins
            Get.dialog(
              EmptyWalletDialog(
                onCancelTap: () => Get.back(),
                onContinueTap: () {
                  Get.back();
                  Get.bottomSheet(const BottomDiamondShop());
                },
                walletCoin: walletCoin,
              ),
            );
          }
        } else {
          cardController.undo();
        }
      },
    );
  }

  void initInterstitialAds() {
    CommonFun.interstitialAd(
      (ad) {
        interstitialAd = ad;
      },
      adMobIntId: Platform.isIOS ? settingAppData?.admobIntIos : settingAppData?.admobInt,
    );
  }

  void onIndexChange(int index) {
    currentProfileIndex = index;
    notifyListeners();
  }

  void onNotificationTap() {
    CommonFun.isBloc(
      userData,
      onCompletion: () {
        Get.to(() => const NotificationScreen());
      },
    );
  }

  void onLivesBtnClick() {
    Get.to(() => const LiveGridScreen());
  }

  void onSearchTap() {
    CommonFun.isBloc(
      userData,
      onCompletion: () {
        Get.to(() => const SearchScreen());
      },
    );
  }

  void onTitleTap() {
    CommonFun.isBloc(
      userData,
      onCompletion: () {
        Get.to(() => const MapScreen());
      },
    );
  }

  void onImageTap() {
    CommonFun.isBloc(
      userData,
      onCompletion: () {
        Get.to(() => UserDetailScreen(
            userData: userList[currentProfileIndex],
            onUpdateUser: (userData) {
              print('ON IMAGE TAP : ${userData?.toJson()}');
              _toggleLikeStatus(userData?.isLiked ?? false);
            }));
      },
    );
  }

  bool onUndo(int? previousIndex, int currentIndex, CardSwiperDirection direction) {
    currentProfileIndex = currentIndex;
    notifyListeners();
    return true;
  }

  FutureOr<bool> onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    // Handle user block status
    if (userData?.isBlock == 1) {
      CommonUI.snackBarWidget(S.current.userBlock);
      return false;
    }

    // Update the profile index and count, but avoid unnecessary UI refresh
    int newProfileIndex = currentIndex ?? 0;

    if (currentProfileIndex != newProfileIndex) {
      currentProfileIndex = newProfileIndex;
      notifyListeners();
    }

    // Trigger API call if near the end of the list
    if (userList.length - 3 == currentProfileIndex || userList.length - 1 == currentProfileIndex) {
      exploreScreenApiCall();
    }
    return true;
  }

  void onLikeDislikeTap(bool isLikeAction) {
    _suggestView();

    if (isSwipeDisable) return;

    if (likeStatus == 1) return;

    // Set the like/dislike status based on the action
    isLikeDisLikeStatus = isLikeAction;
    likeStatus = 1;
    notifyListeners();

    // Delay to perform the swipe action and reset status
    Future.delayed(const Duration(milliseconds: 250), () {
      likeStatus = 0;
      notifyListeners();
      cardController.swipe(isLikeAction ? CardSwiperDirection.right : CardSwiperDirection.left);
    });

    // Avoid redundant API call if the status is already set
    if (userList[currentProfileIndex].isLiked == isLikeAction) return;

    // Update liked status via API
    ApiProvider().updateLikedProfile(userList[currentProfileIndex].id).then((value) {
      // Revert the like status if the API update fails
      if (value.status == false) {
        userList[currentProfileIndex].isLiked = !isLikeAction;
      }
    });
    // Toggle the like status in the list
    _toggleLikeStatus(isLikeAction);
  }

  void _toggleLikeStatus(bool isLike) {
    for (var element in userList) {
      if (element.id == userList[currentProfileIndex].id) {
        element.isLiked = isLike;
      }
    }
    notifyListeners();
  }

  void onSuggestPhotoTap(bool value, {bool isSwipe = false}) {
    isSwipeDisable = value;
    suggestPhotoTapStatus = 1;
    if (isSwipe) {
      isSwipeDisable = false;
    }
    notifyListeners();
    PrefService.saveInt(PrefConst.suggestPhotoTap, 1);
  }

  void onTapSwipeView() {
    suggestSwipeStatus = 1;
    notifyListeners();
    PrefService.saveInt(PrefConst.suggestSwipe, 1);
  }

  void onImageLeftTap(PageController pageController, int currentImageIndex) {
    if (currentImageIndex == 0) return;
    pageController.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  void onImageRightTap(PageController pageController, int currentImageIndex, int imageLength) {
    if (imageLength - 1 == currentImageIndex) return;
    pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  @override
  void dispose() {
    cardController.dispose();
    super.dispose();
  }
}
