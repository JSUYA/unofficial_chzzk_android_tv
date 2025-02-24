import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/constants/dimensions.dart';
import '../../../../common/constants/styles.dart';
import '../../../../common/widgets/center_widgets.dart';
import '../../../../common/widgets/focused_widget.dart';
import '../../../../common/widgets/rounded_container.dart';

import '../../../../utils/router/app_router.dart';
import '../../controller/vod_controller.dart';
import '../../model/vod.dart';
import './vod_container_widgets.dart';

class VodContainer extends ConsumerWidget {
  const VodContainer({
    super.key,
    this.autofocus = false,
    required this.vod,
    required this.infoWidget,
  });

  final bool autofocus;
  final Vod vod;

  /// Vod info is different when using in Channel Vod Container.
  final Widget Function(bool? hasFocus) infoWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoundedContainer(
      backgroundColor: AppColors.greyContainerColor,
      borderRadius: 12.0,
      width: Dimensions.videoThumbnailWidth,
      child: FocusedOutlinedButton(
        autofocus: autofocus,
        onPressed: () async {
          if (vod.channel.personalData?.privateUserBlock == true) {
            return;
          }

          final vodResponse = await ref
              .read(vodControllerProvider.notifier)
              .getVodPlayback(videoNo: vod.videoNo);

          if (context.mounted) {
            if (vodResponse != null) {
              context.pushNamed(AppRoute.vodStreaming.routeName, extra: {
                'vodPath': vodResponse,
                'vod': vod,
              });
            }
          }
        },
        child: (hasFocus) => vod.channel.personalData?.privateUserBlock == true
            ? const CenteredText(text: '차단한 유저의 영상입니다')
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Dimensions.videoThumbnailWidth,
                    height: Dimensions.videoThumbnailHeight,
                    child: Stack(
                      children: [
                        VodThumbnail(vod: vod),
                        VodDuration(durationInSeconds: vod.duration),
                        VodPublishDateAt(publishDateAt: vod.publishDateAt),
                      ],
                    ),
                  ),
                  // Info Widget
                  Expanded(
                    child: infoWidget(hasFocus),
                  ),
                ],
              ),
      ),
    );
  }
}
