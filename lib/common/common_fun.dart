import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/notification/user_notification.dart';
import 'package:orange_ui/model/social/post/add_comment.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/firebase_res.dart';
import 'package:video_compress/video_compress.dart';

class CommonFun {
  static Future<void> interstitialAd(Function(InterstitialAd ad) onAdLoaded,
      {required String? adMobIntId}) async {
    InterstitialAd.load(
      adUnitId: adMobIntId ?? '',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  static void bannerAd(Function(Ad ad) ad, {required String? bannerId}) {
    BannerAd(
      adUnitId: bannerId ?? '',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: ad,
        onAdFailedToLoad: (ad, err) {
          // print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  static String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    // if (diff.inDays > 365) {
    //   return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"}";
    // }
    // if (diff.inDays > 30) {
    //   return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"}";
    // }
    if (diff.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(d);
    }
    if (diff.inDays > 0) {
      if (diff.inDays == 1) {
        return "Yesterday";
      }
      return "${diff.inDays} days";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  static String readTimestamp(double timestamp) {
    var now = DateTime.now();
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp.toInt() * 1000);
    var time = '';
    if (now.day == date.day) {
      time = DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
      return time;
    }
    if (now.weekday > date.weekday) {
      time = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
      return time;
    }
    if (now.month == date.month) {
      time =
          DateFormat('dd/MMM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
      return time;
    }
    return time;
  }

  static String getConversationID({required int? myId, required int? otherUserId}) {
    String conversationID = '${myId}_$otherUserId';
    List<String> v = conversationID.split('_');
    v.sort((a, b) {
      return int.parse(a).compareTo(int.parse(b));
    });
    conversationID = v.join('_');
    return conversationID;
  }

  static getLastMsg({required String msgType, required String msg}) {
    return msgType == FirebaseRes.image
        ? FirebaseRes.imageText
        : msgType == FirebaseRes.video
            ? FirebaseRes.videoText
            : msg;
  }

  static String getProfileImage({List<Images>? images, int? index}) {
    String profileImage = '';
    List<Images> tempList = images ?? [];
    if (index != null) {
      if (tempList.isNotEmpty) {
        return '${ConstRes.aImageBaseUrl}${tempList[index].image?.replaceAll(ConstRes.aImageBaseUrl, '')}';
      }
      return '';
    }
    if (tempList.isNotEmpty) {
      profileImage = tempList.first.image ?? '';
      return '${ConstRes.aImageBaseUrl}${profileImage.replaceAll(ConstRes.aImageBaseUrl, '')}';
    }
    return '';
  }

  static bool isContentAvailable({List<Content>? content}) {
    if (content != null || content!.isNotEmpty) {
      return true;
    }
    return false;
  }

  static String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (twoDigits(duration.inHours) == '00') {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static String formatHHMMSS(int second) {
    int seconds = second;

    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  static double getWidth(int? count) {
    String value = NumberFormat.compact().format(count ?? 0);
    if (value.length == 3) {
      return 58.0;
    } else if (value.length == 4) {
      return 68.0;
    } else if (value.length == 2) {
      return 50.0;
    }
    return 43.0;
  }

  static String getNotificationType(UserNotificationData? notificationData) {
    return notificationData?.type == 1
        ? '${notificationData?.dataUser?.fullname} has started following you.'
        : notificationData?.type == 2
            ? '${notificationData?.dataUser?.fullname} has commented on your post.'
            : notificationData?.type == 3
                ? '${notificationData?.dataUser?.fullname} has liked your post.'
                : notificationData?.type == 4
                    ? '${notificationData?.dataUser?.fullname} ${S.current.hasLikedYourProfileYouShouldCheckTheirProfile}'
                    : '';
  }

  static void isBloc(RegistrationUserData? userData, {VoidCallback? onCompletion}) {
    if (userData?.isBlock == 1) {
      CommonUI.snackBarWidget(S.current.userBlock);
    } else {
      onCompletion?.call();
    }
  }

  static Future<File> getFileThumbnail(String? path) async {
    final thumbnailFile = await VideoCompress.getFileThumbnail(path ?? '');
    return thumbnailFile;
  }
}
