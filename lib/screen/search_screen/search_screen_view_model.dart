import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/model/setting.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/map_screen/map_screen.dart';
import 'package:orange_ui/screen/user_detail_screen/user_detail_screen.dart';
import 'package:orange_ui/service/pref_service.dart';
import 'package:stacked/stacked.dart';

class SearchScreenViewModel extends BaseViewModel {
  String selectedTab = '';
  int selectedTabId = 0;
  TextEditingController searchController = TextEditingController();
  List<Interest> tabList = [];
  List<RegistrationUserData> searchUsers = [];
  bool isLoading = false;
  BannerAd? bannerAd;
  ScrollController scrollController = ScrollController();

  Appdata? settingAppData;

  void init() {
    getSettingData();
    getInterestApiCall();
    getSearchByUser();
    fetchScrollData();
  }

  void getInterestApiCall() async {
    await PrefService.getInterest().then((value) {
      if (value != null && value.status!) {
        tabList = value.data ?? [];
        notifyListeners();
      }
    });
  }

  void fetchScrollData() {
    scrollController.addListener(
      () {
        if (scrollController.offset >= scrollController.position.maxScrollExtent && !isLoading) {
          if (selectedTab.isEmpty) {
            getSearchByUser();
          } else {
            getSearchById(selectedTabId);
          }
        }
      },
    );
  }

  Timer? _timer;

  void getSearchByUser() async {
    isLoading = true;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () async {
      final response = await ApiProvider().searchUser(
        searchKeyword: searchController.text,
        start: searchUsers.length,
      );

      if (response.data != null) {
        for (var element in response.data!) {
          if (!searchUsers.any((user) => user.id == element.id)) {
            searchUsers.add(element);
          }
        }
      }

      isLoading = false;
      notifyListeners();
    });
  }

  void getSearchById(int interestId) async {
    isLoading = true;
    notifyListeners();
    ApiProvider()
        .searchUserById(
            searchKeyword: searchController.text, interestId: interestId, start: searchUsers.length)
        .then((value) {
      List<String> list = searchUsers.map((e) => e.id?.toString() ?? '').toList();
      value.data?.forEach((element) {
        if (!list.contains(element.id?.toString())) {
          searchUsers.add(element);
        }
      });
      isLoading = false;
      notifyListeners();
    });
  }

  void onBackBtnTap() {
    if (selectedTab == '') {
      Get.back();
    } else {
      selectedTab = '';
      searchUsers = [];
      getSearchByUser();
      notifyListeners();
    }
  }

  void onSearchingUser(String value) {
    searchUsers = [];
    if (searchController.text.isEmpty) {
      searchController.clear();
    }
    if (selectedTab.isNotEmpty) {
      getSearchById(selectedTabId);
    } else {
      getSearchByUser();
    }
  }

  void onLocationTap() {
    Get.to(() => const MapScreen());
  }

  void onTabSelect(Interest value) {
    selectedTab = value.title ?? '';
    selectedTabId = value.id ?? -1;
    searchUsers = [];
    getSearchById(selectedTabId);
    notifyListeners();
  }

  void onUserTap(RegistrationUserData? data) {
    Get.to(() => UserDetailScreen(userData: data));
  }

  void getBannerAd() {
    CommonFun.bannerAd((ad) {
      bannerAd = ad as BannerAd;
      notifyListeners();
    }, bannerId: Platform.isIOS ? settingAppData?.admobBannerIos : settingAppData?.admobBanner);
  }

  void getSettingData() {
    PrefService.getSettingData().then((value) {
      settingAppData = value?.appdata;
      getBannerAd();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
