import 'package:cached_network_image/cached_network_image.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:orange_ui/common/common_fun.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/screen/comment_sheet/comment_sheet_view_model.dart';
import 'package:orange_ui/utils/asset_res.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';
import 'package:orange_ui/utils/style_res.dart';

class BottomCommentField extends StatelessWidget {
  final CommentSheetViewModel model;

  const BottomCommentField({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.white,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const Divider(color: ColorRes.greyShade200, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: CommonFun.getProfileImage(images: model.userData?.images),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return CommonUI.profileImagePlaceHolder(
                            name: model.userData?.fullname, borderRadius: 7, heightWidth: 40);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(color: ColorRes.greyShade200),
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: DetectableTextField(
                                  controller: model.detectableTextFieldController,
                                  style: const TextStyle(
                                      color: ColorRes.dimGrey3, fontSize: 14, fontFamily: FontRes.medium),
                                  textCapitalization: TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 15, right: 15, bottom: 16),
                                      border: InputBorder.none,
                                      hintText: S.of(context).addComment,
                                      hintStyle: const TextStyle(
                                          fontFamily: FontRes.medium, fontSize: 12, color: ColorRes.dimGrey3)),
                                  textAlignVertical: TextAlignVertical.center),
                            ),
                          ),
                          InkWell(
                            onTap: model.onCommentSend,
                            child: Container(
                              height: 35,
                              width: 35,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: StyleRes.linearGradient,
                              ),
                              child: Image.asset(AssetRes.share, height: 15, alignment: Alignment.centerRight),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
