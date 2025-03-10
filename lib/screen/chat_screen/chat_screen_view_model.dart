import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/common/confirmation_dialog.dart';
import 'package:orange_ui/common/video_upload_dialog.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/chat_and_live_stream/chat.dart';
import 'package:orange_ui/model/setting.dart';
import 'package:orange_ui/model/store_file_give_path.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/bottom_diamond_shop/bottom_diamond_shop.dart';
import 'package:orange_ui/screen/chat_screen/widgets/image_video_send_sheet.dart';
import 'package:orange_ui/screen/chat_screen/widgets/image_view_page.dart';
import 'package:orange_ui/screen/chat_screen/widgets/item_selection_dialog_android.dart';
import 'package:orange_ui/screen/chat_screen/widgets/unblock_user_dialog.dart';
import 'package:orange_ui/screen/explore_screen/widgets/reverse_swipe_dialog.dart';
import 'package:orange_ui/screen/user_detail_screen/user_detail_screen.dart';
import 'package:orange_ui/screen/user_report_screen/report_sheet.dart';
import 'package:orange_ui/screen/video_preview_screen/video_preview_screen.dart';
import 'package:orange_ui/screen/video_preview_screen/video_preview_screen_view_model.dart';
import 'package:orange_ui/service/pref_service.dart';
import 'package:orange_ui/utils/app_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/firebase_res.dart';
import 'package:orange_ui/utils/pref_res.dart';
import 'package:stacked/stacked.dart';

class ChatScreenViewModel extends BaseViewModel {
  var db = FirebaseFirestore.instance;
  late DocumentReference documentSender;
  late DocumentReference documentReceiver;
  late CollectionReference drChatMessages;
  ImagePicker picker = ImagePicker();

  TextEditingController textMsgController = TextEditingController();

  ScrollController scrollController = ScrollController();

  File? chatImage;

  XFile? _pickedFile;
  String imagePath = '';
  String selectedItem = S.current.image;
  String blockUnblock = S.current.block;
  List<ChatMessage> chatData = [];
  String deletedId = '';

  StreamSubscription<QuerySnapshot<ChatMessage>>? chatStream;
  StreamSubscription<DocumentSnapshot<Conversation>>? conUserStream;

  Conversation conversation;
  RegistrationUserData? registrationUserData;
  RegistrationUserData? receiverUserData;

  Map<String, List<ChatMessage>>? grouped;
  int startingNumber = 30;
  List<String> notDeletedIdentity = [];
  List<String> timeStamp = [];
  bool isLongPress = false;
  int walletCoin = 0;
  bool isSelected = false;
  bool isBlock = false;
  bool isBlockOther = false;
  static String conversationID = '';

  Appdata? settingAppData;

  ChatScreenViewModel(this.conversation);

  void init() {
    conversationID = conversation.conversationId ?? '';
    getPrefData();
    scrollToGetChat();
  }

  Future<void> getPrefData() async {
    await PrefService.getUserData().then((value) {
      registrationUserData = value;
      blockUnblock = conversation.block == true ? S.current.unBlock : S.current.block;
      isBlock = conversation.block == true ? true : false;
      isBlockOther = conversation.blockFromOther == true ? true : false;
    });
    PrefService.getSettingData().then((value) {
      settingAppData = value?.appdata;
      notifyListeners();
    });
    getProfileAPi();
    initFireBaseData();
  }

  Future<void> getProfileAPi() async {
    ApiProvider().getProfile(userID: conversation.user?.userid).then((value) {
      receiverUserData = value?.data;
      notifyListeners();
    });

    ApiProvider().getProfile(userID: PrefService.userId).then((value) async {
      registrationUserData = value?.data;
      walletCoin = value?.data?.wallet ?? 0;
      isSelected = await PrefService.getDialog(PrefConst.isMessageDialog) ?? false;
      blockUnblock = value?.data?.blockedUsers?.contains('${conversation.user?.userid}') == true
          ? S.current.unBlock
          : S.current.block;
      notifyListeners();
      await PrefService.saveUser(value?.data);
    });
  }

  // initialise firebase
  void initFireBaseData() {
    documentReceiver = db
        .collection(FirebaseRes.userChatList)
        .doc('${conversation.user?.userid}')
        .collection(FirebaseRes.userList)
        .doc('${registrationUserData?.id}');
    documentSender = db
        .collection(FirebaseRes.userChatList)
        .doc('${registrationUserData?.id}')
        .collection(FirebaseRes.userList)
        .doc('${conversation.user?.userid}');

    if (conversation.conversationId == null) {
      conversation.setConversationId(CommonFun.getConversationID(
          myId: registrationUserData?.id, otherUserId: conversation.user?.userid));
    }

    drChatMessages = db
        .collection(FirebaseRes.chat)
        .doc(conversation.conversationId)
        .collection(FirebaseRes.chat);

    getChat();
  }

  Future<void> minusCoinApi() async {
    await ApiProvider().minusCoinFromWallet(settingAppData?.messagePrice);
  }

  void scrollToGetChat() {
    scrollController.addListener(() {
      if (scrollController.offset == scrollController.position.maxScrollExtent) {
        getChat();
      }
    });
  }

  void onUserTap() {
    Get.to(() => UserDetailScreen(
          userId: conversation.user?.userid,
        ));
  }

  void onCancelBtnClick() {
    timeStamp = [];
    notifyListeners();
  }

  // chat item delete method
  void chatDeleteDialog() {
    Get.dialog(ConfirmationDialog(
      onTap: onDeleteBtnClick,
      description: S.current.afterDeletingTheChatYouCanNotRestoreOurMessage,
      dialogSize: 1.6,
      padding: const EdgeInsets.symmetric(horizontal: 40),
    ));
  }

  void onDeleteBtnClick() {
    for (int i = 0; i < timeStamp.length; i++) {
      drChatMessages.doc(timeStamp[i]).update(
        {
          FirebaseRes.noDeleteIdentity: FieldValue.arrayRemove(
            ['${registrationUserData?.id}'],
          )
        },
      );
      chatData.removeWhere(
        (element) => element.time.toString() == timeStamp[i],
      );
    }
    timeStamp = [];
    Get.back();
    notifyListeners();
  }

  // long press to select chat method
  void onLongPress(ChatMessage? data) {
    if (!timeStamp.contains('${data?.time?.round()}')) {
      timeStamp.add('${data?.time?.round()}');
    } else {
      timeStamp.remove('${data?.time?.round()}');
    }
    isLongPress = true;
    notifyListeners();
  }

  void unblockDialog() {
    Get.dialog(UnblockUserDialog(
      unblockUser: unBlockUser,
      name: conversation.user?.username,
    ));
  }

  // more btn event
  Future<void> onMoreBtnTap(String value) async {
    if (value == S.current.block) {
      blockUser();
    }
    if (value == S.current.unBlock) {
      unBlockUser();
    }

    if (value == AppRes.report) {
      Get.bottomSheet(
        ReportSheet(
          reportId: conversation.user?.userid,
          userData: receiverUserData,
          fullName: conversation.user?.username,
          profileImage: conversation.user?.image,
          age: int.parse(conversation.user?.age ?? '0'),
          address: conversation.user?.city,
          reportType: 1,
        ),
        isScrollControlled: true,
      );
    }
  }

  Future<void> blockUser() async {
    ApiProvider().updateBlockList(conversation.user?.userid);
    await documentSender
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) {
              return value.toFirestore();
            })
        .update({
      FirebaseRes.block: true,
    });
    await documentReceiver
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) {
              return value.toFirestore();
            })
        .update({
      FirebaseRes.blockFromOther: true,
    });
    blockUnblock = S.current.unBlock;
    isBlock = true;
    isBlockOther = true;
    notifyListeners();
  }

  Future<void> unBlockUser() async {
    ApiProvider().updateBlockList(conversation.user?.userid);
    await documentSender
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) {
              return value.toFirestore();
            })
        .update({
      FirebaseRes.block: false,
    });
    await documentReceiver
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) {
              return value.toFirestore();
            })
        .update({
      FirebaseRes.blockFromOther: false,
    });
    blockUnblock = S.current.block;
    isBlock = false;
    isBlockOther = false;
    notifyListeners();
  }

  // navigate to imageviewScreen
  void onImageTap(ChatMessage? imageData) {
    Get.to(
      () => ImageViewPage(
        userData: imageData,
        onBack: () {
          Get.back();
        },
      ),
    )?.then((value) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: ColorRes.transparent,
        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ));
    });
  }

  // send a text message
  void onSendBtnTap() {
    if (conversation.blockFromOther == true) {
      CommonUI.snackBarWidget(S.current.thisUserBlockYou);
      textMsgController.clear();
      return;
    }

    String textMessage = textMsgController.text.trim();
    if (textMessage.isEmpty) return;

    if (registrationUserData?.isFake == 1) {
      textMsgController.clear();
      firebaseMsgUpdate(msgType: FirebaseRes.msg, textMessage: textMessage);
      return;
    }

    int messagePrice = settingAppData?.messagePrice ?? 0;
    if (messagePrice == 0) {
      textMsgController.clear();
      firebaseMsgUpdate(msgType: FirebaseRes.msg, textMessage: textMessage);
    } else if (walletCoin >= messagePrice) {
      isSelected ? onMessageSent() : getChatMsgDialog(onContinueTap: onTextMsgContinueClick);
    } else {
      emptyDialog();
    }
  }

  void onTextMsgContinueClick(bool isSelected) {
    PrefService.setDialog(PrefConst.isMessageDialog, isSelected);
    minusCoinApi().then(
      (value) {
        Get.back();
        firebaseMsgUpdate(
          msgType: FirebaseRes.msg,
          textMessage: textMsgController.text.trim(),
        );
        textMsgController.clear();
      },
    );
  }

  void onMessageSent() {
    String text = textMsgController.text;
    textMsgController.clear();
    minusCoinApi().then(
      (value) async {
        getProfileAPi();
        firebaseMsgUpdate(msgType: FirebaseRes.msg, textMessage: text.trim());
      },
    );
  }

  void onPlusTap(int type) {
    minusCoinApi().then(
      (value) {
        getProfileAPi();
        onAddBtnTap(type);
      },
    );
  }

  void onPlusBtnClick(int type) {
    if (registrationUserData?.isFake == 1) {
      onAddBtnTap(type);
      return;
    }

    int messagePrice = settingAppData?.messagePrice ?? 0;
    if (messagePrice == 0) {
      onAddBtnTap(type);
    } else if (walletCoin >= messagePrice) {
      isSelected
          ? onPlusTap(type)
          : getChatMsgDialog(onContinueTap: (isSelected) => onPlusContinueClick(isSelected, type));
    } else {
      emptyDialog();
    }
  }

  void onPlusContinueClick(bool isSelected, int type) {
    PrefService.setDialog(PrefConst.isMessageDialog, isSelected);
    minusCoinApi().then(
      (value) {
        Get.back();
        onAddBtnTap(type);
      },
    );
  }

  // Add btn to choose photo or video method
  void onAddBtnTap(int type) async {
    if (conversation.blockFromOther == true) {
      CommonUI.snackBarWidget(S.current.thisUserBlockYou);
      return;
    }
    Get.bottomSheet(
        ItemSelectionDialogAndroid(onImageBtnClick: () {
          Get.back();
          itemSelectImage(type);
        }, onVideoBtnClick: () {
          Get.back();
          itemSelectVideo(type);
        }),
        backgroundColor: ColorRes.transparent,
        isScrollControlled: true);
  }

  // selected video or image method
  void itemSelectImage(int type) async {
    selectedItem = S.current.image;
    final XFile? photo = await picker.pickImage(
        source: type == 0 ? ImageSource.gallery : ImageSource.camera,
        imageQuality: AppRes.quality,
        maxHeight: AppRes.maxHeight,
        maxWidth: AppRes.maxWidth);

    if (photo == null || photo.path.isEmpty) return;
    File cameraImage = File(photo.path);
    Get.bottomSheet(
        ImageVideoSendSheet(
            image: cameraImage,
            onSendBtnClick: (msg, image) async {
              CommonUI.lottieLoader();
              StoreFileGivePath response =
                  await ApiProvider().getStoreFileGivePath(image: cameraImage);
              Get.back();
              if (response.status == true) {
                firebaseMsgUpdate(
                    image: response.path, msgType: FirebaseRes.image, textMessage: msg);
              } else {
                CommonUI.snackBarWidget(response.message);
              }
            },
            selectedItem: selectedItem),
        isScrollControlled: true);
  }

  void itemSelectVideo(int type) async {
    selectedItem = S.current.videoCap;
    _pickedFile = await picker.pickVideo(
        source: type == 0 ? ImageSource.gallery : ImageSource.camera,
        maxDuration: const Duration(seconds: 60));

    if (_pickedFile == null || _pickedFile!.path.isEmpty) return;

    // calculating file size
    final videoFile = File(_pickedFile?.path ?? '');
    int sizeInBytes = videoFile.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb <= AppRes.maxVideoUploadSize) {
      File videoThumbnail = await CommonFun.getFileThumbnail(_pickedFile?.path);
      Get.bottomSheet(
        ImageVideoSendSheet(
            image: videoThumbnail,
            selectedItem: selectedItem,
            onSendBtnClick: (msg, image) async {
              CommonUI.lottieLoader();
              // Run both API calls concurrently
              final responses = await Future.wait([
                ApiProvider().getStoreFileGivePath(image: videoThumbnail),
                ApiProvider().getStoreFileGivePath(image: videoFile)
              ]);

              final imageResponse = responses[0];
              final videoResponse = responses[1];
              if (imageResponse.status == true && videoResponse.status == true) {
                firebaseMsgUpdate(
                    textMessage: msg,
                    video: videoResponse.path,
                    msgType: FirebaseRes.video,
                    image: imageResponse.path);
              }

              Get.back();
              Get.back();
            }),
        isScrollControlled: true,
      );
    } else {
      Get.dialog(VideoUploadDialog(
        selectAnother: () {
          Get.back();
          itemSelectVideo(type);
        },
      ));
    }
  }

  //  video preview screen navigate
  Future<void> onVideoItemClick(ChatMessage? data) async {
    await Get.to(() => VideoPreviewScreen(videoUrl: data?.video, type: VideoType.other))
        ?.then((value) {});
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorRes.white,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ));
  }

  Future<void> getChat() async {
    try {
      // Fetch deleted message ID
      final docSnapshot = await documentSender
          .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) => value.toFirestore(),
          )
          .get();

      deletedId = docSnapshot.data()?.deletedId?.toString() ?? '';
      notifyListeners();

      // Stream chat messages
      chatStream = drChatMessages
          .where(FirebaseRes.noDeleteIdentity, arrayContains: '${registrationUserData?.id}')
          .where(FirebaseRes.time,
              isGreaterThan: deletedId.isNotEmpty ? double.parse(deletedId) : 0.0)
          .orderBy(FirebaseRes.time, descending: true)
          .limit(startingNumber)
          .withConverter(
            fromFirestore: ChatMessage.fromFirestore,
            toFirestore: (ChatMessage value, options) => value.toFirestore(),
          )
          .snapshots()
          .listen((snapshot) {
        chatData = snapshot.docs.map((doc) => doc.data()).toList();

        final now = DateTime.now();
        Map<String, List<ChatMessage>> customGrouped = {};

        for (var message in chatData) {
          if (message.time != null) {
            final time = DateTime.fromMillisecondsSinceEpoch(message.time!.toInt());
            final formattedDate = DateFormat(AppRes.dMY).format(time);

            String groupKey;
            if (formattedDate == DateFormat(AppRes.dMY).format(now)) {
              groupKey = S.current.today;
            } else if (formattedDate ==
                DateFormat(AppRes.dMY).format(now.subtract(const Duration(days: 1)))) {
              groupKey = S.current.yesterday;
            } else {
              groupKey = formattedDate;
            }

            // Add message to the correct group
            customGrouped.putIfAbsent(groupKey, () => []).add(message);
          }

          grouped = customGrouped;
          startingNumber += 45;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error fetching chat: $e');
    }
  }

  //Firebase message update method
  Future<void> firebaseMsgUpdate({
    required String msgType,
    String? textMessage,
    String? image,
    String? video,
  }) async {
    final int time = DateTime.now().millisecondsSinceEpoch;
    notDeletedIdentity = ['${registrationUserData?.id}', '${conversation.user?.userid}'];

    final messageData = ChatMessage(
      notDeletedIdentities: notDeletedIdentity,
      senderUser: ChatUser(
        username: registrationUserData?.fullname,
        date: time.toDouble(),
        isHost: false,
        isNewMsg: true,
        userid: registrationUserData?.id,
        userIdentity: registrationUserData?.identity,
        image: CommonFun.getProfileImage(images: registrationUserData?.images),
        city: registrationUserData?.live,
        age: registrationUserData?.age.toString(),
      ),
      msgType: msgType,
      msg: textMessage,
      image: image,
      video: video,
      id: conversation.user?.userid?.toString(),
      time: time.toDouble(),
    ).toJson();

    // Store message in Firestore
    await drChatMessages.doc(time.toString()).set(messageData);

    final String lastMessage = CommonFun.getLastMsg(msgType: msgType, msg: textMessage ?? '');

    if (chatData.isEmpty && deletedId.isEmpty) {
      await _initializeConversation(lastMessage, time);
    } else {
      await _updateConversation(lastMessage, time);
    }

    if (receiverUserData?.isNotification == 1) {
      _sendPushNotification(lastMessage);
    }
  }

  Future<void> _initializeConversation(String lastMessage, int time) async {
    final con = conversation.toJson();
    con[FirebaseRes.lastMsg] = lastMessage;

    await Future.wait([
      documentSender.set(con),
      documentReceiver.set(
        Conversation(
          block: false,
          blockFromOther: false,
          conversationId: conversation.conversationId,
          deletedId: '',
          isDeleted: false,
          isMute: false,
          lastMsg: lastMessage,
          newMsg: lastMessage,
          time: time.toDouble(),
          user: ChatUser(
            username: registrationUserData?.fullname,
            date: time.toDouble(),
            isHost: registrationUserData?.isVerified == 2 ? true : false,
            isNewMsg: true,
            userid: registrationUserData?.id,
            userIdentity: registrationUserData?.identity,
            image: CommonFun.getProfileImage(images: registrationUserData?.images),
            city: registrationUserData?.live,
            age: registrationUserData?.age.toString(),
          ),
        ).toJson(),
      ),
    ]);
  }

  Future<void> _updateConversation(String lastMessage, int time) async {
    try {
      final docSnapshot = await documentReceiver
          .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) => value.toFirestore(),
          )
          .get();

      final receiverUser = docSnapshot.data()?.user;
      receiverUser?.isNewMsg = true;

      await Future.wait([
        documentReceiver.update({
          FirebaseRes.isDeleted: false,
          FirebaseRes.time: time.toDouble(),
          FirebaseRes.lastMsg: lastMessage,
          FirebaseRes.user: receiverUser?.toJson(),
        }),
        documentSender.update({
          FirebaseRes.isDeleted: false,
          FirebaseRes.time: time.toDouble(),
          FirebaseRes.lastMsg: lastMessage,
        }),
      ]);
    } catch (e) {
      debugPrint("Error updating conversation: $e");
    }
  }

  void _sendPushNotification(String lastMessage) {
    ApiProvider().pushNotification(
      title: registrationUserData?.fullname ?? '',
      body: lastMessage,
      conversationId: conversation.conversationId ?? '',
      deviceType: receiverUserData?.deviceType,
      token: '${receiverUserData?.deviceToken}',
    );
  }

  void emptyDialog() {
    Get.dialog(
      EmptyWalletDialog(
          onCancelTap: () {
            Get.back();
          },
          onContinueTap: () {
            Get.back();
            Get.bottomSheet(const BottomDiamondShop());
          },
          walletCoin: walletCoin),
    );
  }

  void getChatMsgDialog({required Function(bool isSelected) onContinueTap}) {
    Get.dialog(
      ReverseSwipeDialog(
          onContinueTap: onContinueTap,
          isCheckBoxVisible: true,
          walletCoin: walletCoin,
          title1: S.current.message.toUpperCase(),
          title2: S.current.priceCap,
          dialogDisc: AppRes.messageDisc(settingAppData?.messagePrice),
          coinPrice: '${settingAppData?.messagePrice ?? 0}'),
    ).then((value) {
      getProfileAPi();
    });
  }

  // Dispose Method
  @override
  void dispose() {
    _updateSenderUser(); // Offload Firestore update to a separate method
    _disposeControllers(); // Clean up resources
    super.dispose();
  }

  void _updateSenderUser() async {
    try {
      var docSnapshot = await documentSender
          .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) => value.toFirestore(),
          )
          .get();

      var senderUser = docSnapshot.data()?.user;
      if (senderUser != null) {
        senderUser.isNewMsg = false;
        await documentSender.update({FirebaseRes.user: senderUser.toJson()});
      }
    } catch (e) {
      debugPrint("Error updating sender user: $e");
    }
  }

  void _disposeControllers() {
    chatStream?.cancel();
    conUserStream?.cancel();
    scrollController.dispose();
    textMsgController.dispose();
    conversationID = '';
  }
}
