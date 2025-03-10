import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/common/video_upload_dialog.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/video_preview_screen/video_preview_screen.dart';
import 'package:orange_ui/screen/video_preview_screen/video_preview_screen_view_model.dart';
import 'package:orange_ui/service/pref_service.dart';
import 'package:stacked/stacked.dart';

class LiveStreamApplicationScreenViewModel extends BaseViewModel {
  void init() {
    getPrefData();
  }

  TextEditingController aboutController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController videoController = TextEditingController();
  TextEditingController socialProfileController = TextEditingController();
  ImagePicker picker = ImagePicker();

  List<String> socialLinks = [];

  int fieldCount = 1;
  String? videoImageFile;
  File? videoFile;
  XFile? _pickedFile;
  bool isVideoAttach = true;
  bool isAbout = false;
  bool isLanguages = false;
  bool isIntroVideo = false;
  bool isSocialLink = false;

  RegistrationUserData? userData;

  void onVideoControllerChange(String? value) {
    if (videoController.text == '' || videoController.text.length == 1) {
      notifyListeners();
    }
  }

  void onPlusBtnTap() {
    if (socialProfileController.text.trim().isEmpty) return;
    fieldCount = fieldCount + 1;
    socialLinks.add(socialProfileController.text.trim());
    socialProfileController.clear();
    if (socialLinks.isNotEmpty) {
      isSocialLink = false;
    }
    notifyListeners();
  }

  void onRemoveBtnTap(String text) {
    socialLinks.remove(text);
    notifyListeners();
  }

  void onSubmitBtnTap() {
    if (!isValid()) return;
    CommonUI.lottieLoader();
    ApiProvider()
        .applyForLive(
            videoFile, aboutController.text, languageController.text, socialLinks.join(','))
        .then((value) {
      Get.back();
      userData?.canGoLive = 1;
      Get.back(result: userData);

      CommonUI.snackBarWidget(value.message);
    });
  }

  bool isValid() {
    int i = 0;
    isAbout = false;
    isLanguages = false;
    isSocialLink = false;
    isIntroVideo = false;
    notifyListeners();
    if (aboutController.text == '') {
      isAbout = true;
      i++;
      return false;
    } else if (languageController.text == '') {
      isLanguages = true;
      i++;
      return false;
    } else if (videoImageFile == null || videoImageFile!.isEmpty) {
      isIntroVideo = true;
      i++;
      return false;
    } else if (socialLinks.isEmpty) {
      CommonUI.snackBarWidget(S.current.pleaseAddSocialLinks);
      isSocialLink = true;
      i++;
    }
    notifyListeners();
    return i == 0 ? true : false;
  }

  void onVideoPlayBtnTap() {
    if (videoFile == null || videoFile!.path.isEmpty) return;
    CommonUI.lottieLoader();
    ApiProvider().getStoreFileGivePath(image: videoFile).then((value) {
      Get.back();
      Get.to(() => VideoPreviewScreen(videoUrl: value.path, type: VideoType.other));
    });
  }

  void onVideoChangeBtnTap() {
    imagePicker();
  }

  void onAttachBtnTap() {
    imagePicker();
  }

  void imagePicker() async {
    _pickedFile = await picker
        .pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    )
        .onError((PlatformException error, stackTrace) {
      CommonUI.snackBarWidget(error.message ?? '');
      return null;
    });
    if (_pickedFile == null || _pickedFile!.path.isEmpty) return;
    final file = File(_pickedFile?.path ?? '');
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb <= 50) {
      showDialog(
          context: Get.context!,
          builder: (context) {
            return Center(child: CommonUI.lottieWidget());
          },
          barrierDismissible: false);

      videoFile = File(_pickedFile?.path ?? '');
      videoImageFile = (await CommonFun.getFileThumbnail(_pickedFile?.path)).path;

      isVideoAttach = false;
      Get.back();
      notifyListeners();
    } else {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return VideoUploadDialog(
            selectAnother: () {
              Get.back();
              imagePicker();
            },
          );
        },
      );
    }
  }

  void getPrefData() async {
    userData = await PrefService.getUserData();
  }
}
