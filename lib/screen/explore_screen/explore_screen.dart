import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orange_ui/common/dashboard_top_bar.dart';
import 'package:orange_ui/screen/explore_screen/explore_screen_view_model.dart';
import 'package:orange_ui/screen/explore_screen/widgets/bottom_bottons.dart';
import 'package:orange_ui/screen/explore_screen/widgets/full_image_view.dart';
import 'package:stacked/stacked.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExploreScreenViewModel>.reactive(
      onViewModelReady: (model) {
        model.init();
      },
      viewModelBuilder: () => ExploreScreenViewModel(),
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardTopBar(
                onNotificationTap: model.onNotificationTap,
                onSearchTap: model.onSearchTap,
                onLivesBtnClick: model.onLivesBtnClick,
                isDating: model.settingAppData?.isDating),
            const SizedBox(height: 20),
            FullImageView(model: model),
            const SizedBox(height: 26),
            if (model.userList.isNotEmpty) BottomButtons(model: model),
            if (model.userList.isNotEmpty) const SizedBox(height: 15),
          ],
        );
      },
    );
  }
}
