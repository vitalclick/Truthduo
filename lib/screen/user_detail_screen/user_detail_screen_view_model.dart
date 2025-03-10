import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/chat_and_live_stream/chat.dart';
import 'package:orange_ui/model/chat_and_live_stream/live_stream.dart';
import 'package:orange_ui/model/setting.dart';
import 'package:orange_ui/model/user/follow_user.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/chat_screen/chat_screen.dart';
import 'package:orange_ui/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:orange_ui/screen/person_streaming_screen/person_streaming_screen.dart';
import 'package:orange_ui/screen/post_screen/post_screen.dart';
import 'package:orange_ui/screen/user_report_screen/report_sheet.dart';
import 'package:orange_ui/service/pref_service.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/firebase_res.dart';
import 'package:orange_ui/utils/urls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';

class UserDetailScreenViewModel extends BaseViewModel {
  FirebaseFirestore db = FirebaseFirestore.instance;

  RegistrationUserData? otherUserData;
  RegistrationUserData? myUserData;
  LiveStreamUser? liveStreamUser;
  InterstitialAd? interstitialAd;
  Appdata? settingAppData;

  bool isLoading = false;
  bool moreInfo = false;
  bool save = false;
  bool showDropdown = false;
  bool isFollow = true;

  List<String?> joinedUsers = [];
  List<String> interestList = [];

  String latitude = '';
  String longitude = '';
  String blockUnBlock = S.current.block;
  String reason = S.current.cyberbullying;

  int? userId;
  int selectedImgIndex = 0;

  double distance = 0.0;

  Function(RegistrationUserData? userData)? onUpdateUser;

  UserDetailScreenViewModel({this.userId, this.otherUserData, this.onUpdateUser});

  void init(bool? showInfo) {
    getSettingData();
    userDetailApiCall();
  }

  Future<void> userProfileApiCall() async {
    isLoading = true;
    try {
      final profileResponse = await ApiProvider().getProfile(userID: userId ?? otherUserData?.id);
      otherUserData = profileResponse?.data;
      print(otherUserData?.toJson());

      // Determine if the user is followed
      isFollow = otherUserData?.followingStatus == 2 || otherUserData?.followingStatus == 3;

      // Process user interests
      final List<String> interestIDs = (otherUserData?.interests ?? '').split(',');
      final prefInterests = await PrefService.getInterest();

      if (prefInterests?.data != null) {
        for (var element in prefInterests!.data!) {
          if (interestIDs.contains('${element.id}') && (element.title?.isNotEmpty ?? false)) {
            interestList.add(element.title!);
          }
        }
      }
    } catch (e) {
      // Handle error if needed, e.g., log error or show UI notification
      debugPrint('Error fetching user profile: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrationUserApiCall() async {
    // Latest userdata
    await ApiProvider().getProfile(userID: PrefService.userId).then((value) {
      myUserData = value?.data;
      blockUnBlock =
          value?.data?.blockedUsers?.contains('${otherUserData?.id}') == true ? S.current.unBlock : S.current.block;
      save = value?.data?.savedProfile?.contains('${otherUserData?.id}') ?? false;
      notifyListeners();
      PrefService.saveUser(value?.data);
    });
  }

  void userDetailApiCall() async {
    userProfileApiCall().then((value) {
      registrationUserApiCall();
    });
    latitude = await PrefService.getLatitude() ?? '';
    longitude = await PrefService.getLongitude() ?? '';

    if (_isValidCoordinate(latitude) && _isValidCoordinate(otherUserData?.latitude)) {
      distance = calculateDistance(
        lat1: double.parse(latitude),
        lon1: double.parse(longitude),
        lat2: double.parse(otherUserData?.latitude ?? '0.0'),
        lon2: double.parse(otherUserData?.longitude ?? '0.0'),
      );
    } else {
      distance = 0;
    }

    notifyListeners();
  }

  double calculateDistance({lat1, lon1, lat2, lon2}) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Helper function to validate coordinates
  bool _isValidCoordinate(String? coord) {
    return coord != null && coord.isNotEmpty && coord != '0.0';
  }

  void onReasonChange(String value) {
    reason = value;
    showDropdown = false;
    notifyListeners();
  }

  void onReasonTap() {
    showDropdown = !showDropdown;
    notifyListeners();
  }

  void onImageSelect(int index) {
    selectedImgIndex = index;
    notifyListeners();
  }

  void onJoinBtnTap() {
    // Extract user images and add the current user to the joined users list
    final images = otherUserData?.images;
    joinedUsers.add(otherUserData?.identity ?? '');

    // Create a new LiveStreamUser instance
    liveStreamUser = LiveStreamUser(
      userId: otherUserData?.id,
      userImage: images != null && images.isNotEmpty ? images[0].image : '',
      id: DateTime.now().millisecondsSinceEpoch,
      watchingCount: 0,
      joinedUser: [],
      isVerified: otherUserData?.isVerified == 2,
      hostIdentity: otherUserData?.identity,
      collectedDiamond: 0,
      agoraToken: '',
      fullName: otherUserData?.fullname ?? '',
      age: otherUserData?.age ?? 0,
      address: otherUserData?.live ?? '',
    );

    // Update Firestore with joined user and increment the watching count
    db.collection(FirebaseRes.liveHostList).doc('${otherUserData?.id}').update({
      FirebaseRes.joinedUser: FieldValue.arrayUnion(joinedUsers),
      FirebaseRes.watchingCount: FieldValue.increment(1),
    }).then((value) {
      // Navigate to PersonStreamingScreen on success
      Get.to(() => const PersonStreamingScreen(), arguments: {
        Urls.aChannelId: otherUserData?.identity,
        Urls.aIsBroadcasting: false,
        Urls.aUserInfo: liveStreamUser,
      });
    }).catchError((e) {
      // Show error snackBar if the user is not live
      CommonUI.snackBarWidget(S.current.userNotLive);
    });
  }

  void onHideInfoTap() {
    notifyListeners();
  }

  void onBackTap() {
    PrefService.getUserData().then((value) {
      if (value?.id == otherUserData?.id) {
        Get.back();
      } else {
        if (interstitialAd != null) {
          interstitialAd?.show().whenComplete(() {
            Get.back();
          });
        } else {
          Get.back();
        }
      }
    });
  }

  void initInterstitialAds() {
    CommonFun.interstitialAd((ad) {
      interstitialAd = ad;
    }, adMobIntId: Platform.isIOS ? settingAppData?.admobIntIos : settingAppData?.admobInt);
  }

  void onMoreBtnTap(String value) {
    if (value == S.current.block) {
      blockUnblockApi(blockProfileId: otherUserData?.id).then((value) {
        registrationUserApiCall();
      });
    } else if (value == S.current.unBlock) {
      blockUnblockApi(blockProfileId: otherUserData?.id).then((value) {
        registrationUserApiCall();
      });
    } else {
      onReportTap();
    }
  }

  Future<void> blockUnblockApi({int? blockProfileId}) async {
    CommonUI.lottieLoader();
    await ApiProvider().updateBlockList(blockProfileId);
    onBackTap();
  }

  void onLikeBtnTap() async {
    if (otherUserData?.isLiked == false) {
      otherUserData?.isLiked = true;
    } else {
      otherUserData?.isLiked = false;
    }
    onUpdateUser?.call(otherUserData);
    notifyListeners();
    await ApiProvider().updateLikedProfile(otherUserData?.id).then(
      (value) {
        if (value.status == false) {
          otherUserData?.isLiked = false;
          notifyListeners();
        }
      },
    );
  }

  void onSaveTap() {
    save = !save;
    ApiProvider().updateSaveProfile(otherUserData?.id);
    notifyListeners();
  }

  void onChatBtnTap() {
    ChatUser chatUser = ChatUser(
      age: '${otherUserData?.age ?? ''}',
      city: otherUserData?.live ?? '',
      image: CommonFun.getProfileImage(images: otherUserData?.images),
      userIdentity: otherUserData?.identity,
      userid: otherUserData?.id,
      isNewMsg: false,
      isHost: otherUserData?.isVerified == 2 ? true : false,
      date: DateTime.now().millisecondsSinceEpoch.toDouble(),
      username: otherUserData?.fullname,
    );
    Conversation conversation = Conversation(
      block: myUserData?.blockedUsers?.contains('${otherUserData?.id}') == true ? true : false,
      blockFromOther: otherUserData?.blockedUsers?.contains('${myUserData?.id}') == true ? true : false,
      conversationId: CommonFun.getConversationID(myId: myUserData?.id, otherUserId: otherUserData?.id),
      deletedId: '',
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
      isDeleted: false,
      isMute: false,
      lastMsg: '',
      newMsg: '',
      user: chatUser,
    );
    Get.to(() => ChatScreen(conversation: conversation))?.then((value) {
      registrationUserApiCall();
    });
  }

  void onShareProfileBtnTap() async {
    BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: otherUserData?.fullname ?? '',
        imageUrl: CommonFun.getProfileImage(images: otherUserData?.images),
        contentDescription: otherUserData?.about ?? '',
        publiclyIndex: true,
        locallyIndex: true);
    BranchLinkProperties lp = BranchLinkProperties();
    lp.addControlParam(Urls.userId, '${otherUserData?.id}');
    if (GetPlatform.isIOS) {
      if (buo.imageUrl != '') {
        FlutterBranchSdk.showShareSheet(buo: buo, linkProperties: lp, messageText: '');
      } else {
        rootBundle.load(AssetRes.appIcon).then((data) {
          FlutterBranchSdk.shareWithLPLinkMetadata(
            buo: buo,
            linkProperties: lp,
            icon: data.buffer.asUint8List(),
            title: otherUserData?.fullname ?? '',
          );
        });
      }
    } else {
      FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp).then((value) {
        if (value.success) {
          Share.share(value.result ?? '', subject: otherUserData?.fullname ?? '');
        } else {
          debugPrint('Something went wrong');
        }
      });
    }
  }

  void onReportTap() {
    Get.bottomSheet(
      ReportSheet(
          reportId: otherUserData?.id,
          fullName: otherUserData?.fullname,
          profileImage: CommonFun.getProfileImage(images: otherUserData?.images),
          age: otherUserData?.age,
          userData: otherUserData,
          address: otherUserData?.live,
          reportType: 1),
      isScrollControlled: true,
    );
  }

  void onFollowUnfollowBtnClick() {
    CommonUI.lottieLoader(isBarrierDismissible: false);

    // Determine the appropriate URL based on follow status
    final url = isFollow ? Urls.aUnfollowUser : Urls.aFollowUser;

    // Prepare parameters for the API request
    final params = {
      Urls.myUserId: PrefService.userId,
      Urls.userId: otherUserData?.id,
    };

    // Make the API call
    ApiProvider().callPost(
        completion: (response) {
          Get.back();
          final followUser = FollowUser.fromJson(response);

          if (followUser.status == true) {
            // Update follow status and follower count accordingly
            isFollow = !isFollow;
            final followerChange = isFollow ? 1 : -1;
            otherUserData?.followerCount(followerChange);
            notifyListeners();
          }
        },
        url: url,
        param: params);
  }

  void onEditBtnClick() {
    Get.to<RegistrationUserData>(() => EditProfileScreen(userData: otherUserData))?.then((value) {
      if (value != null) {
        if (value.id == PrefService.userId) {
          otherUserData = value;
        }
        notifyListeners();
      }
    });
  }

  void onPostBtnClick() {
    Get.to(() => PostScreen(userData: otherUserData));
  }

  void getSettingData() {
    PrefService.getSettingData().then((value) {
      settingAppData = value?.appdata;
      notifyListeners();
      initInterstitialAds();
    });
  }
}
