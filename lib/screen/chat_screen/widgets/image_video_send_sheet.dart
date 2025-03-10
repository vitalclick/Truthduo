import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';
import 'package:orange_ui/utils/style_res.dart';

class ImageVideoSendSheet extends StatelessWidget {
  final File image;
  final String selectedItem;
  final Function(String msg, File? image) onSendBtnClick;

  const ImageVideoSendSheet(
      {Key? key, required this.image, required this.onSendBtnClick, required this.selectedItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController msgController = TextEditingController();
    return Container(
      margin: const EdgeInsets.only(top: 70),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, color: ColorRes.black, size: 30),
                ),
                const Spacer(),
                Text(
                  S.current.sendMedia,
                  style: const TextStyle(
                      color: ColorRes.black, fontSize: 20, fontFamily: FontRes.bold),
                ),
                const Spacer()
              ],
            ),
          ),
          const SizedBox(height: 1),
          const Divider(color: ColorRes.grey),
          const SizedBox(height: 10),
          Text(
            S.current.writeMessage,
            style:
                const TextStyle(color: ColorRes.black, fontFamily: FontRes.semiBold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image, height: 170, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: Container(
                  height: 170,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorRes.grey10,
                  ),
                  child: TextField(
                    controller: msgController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: 9,
                    cursorColor: ColorRes.darkOrange,
                    cursorHeight: 15,
                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontFamily: FontRes.regular, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => onSendBtnClick(msgController.text, image),
            child: Container(
              height: 40,
              width: Get.width / 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), gradient: StyleRes.linearGradient),
              child: Center(
                child: Text(S.current.send,
                    style: const TextStyle(color: ColorRes.white, fontFamily: FontRes.semiBold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
