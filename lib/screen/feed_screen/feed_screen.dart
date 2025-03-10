import 'package:flutter/material.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/common/dashboard_top_bar.dart';
import 'package:orange_ui/screen/feed_screen/feed_screen_view_model.dart';
import 'package:orange_ui/screen/feed_screen/widget/feed_story_bar.dart';
import 'package:orange_ui/screen/post_screen/widget/post_card.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/style_res.dart';
import 'package:stacked/stacked.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedScreenViewModel>.reactive(
      onViewModelReady: (viewModel) => viewModel.init(),
      viewModelBuilder: () => FeedScreenViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: ColorRes.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardTopBar(
                onNotificationTap: model.onNotificationTap,
                onSearchTap: model.onSearchTap,
                onLivesBtnClick: model.onLivesBtnClick,
                isDating: model.settingAppData?.isDating),
            Expanded(
              child: model.isLoading
                  ? CommonUI.lottieWidget()
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          controller: model.scrollController,
                          child: Column(
                            children: [
                              FeedStoryBar(model: model),
                              model.postList.isEmpty
                                  ? CommonUI.noData()
                                  : ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: model.postList.length,
                                      itemBuilder: (context, index) {
                                        return PostCard(
                                          post: model.postList[index],
                                          model: model,
                                          postIndex: index,
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                        model.postList.isEmpty ? CommonUI.noData() : Container()
                      ],
                    ),
            )
          ],
        ),
        floatingActionButton: InkWell(
          onTap: model.onCreatePost,
          child: Container(
            width: 50,
            height: 50,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                gradient: StyleRes.linearGradient),
            child: const Icon(Icons.add_rounded, color: ColorRes.white),
          ),
        ),
      ),
    );
  }
}
