import 'package:video_player/video_player.dart';

class CommonModel {
  CommonModel({
    this.type = "",
    this.isSelected = false,
    this.isSeen = false,
    this.videoPlayerController,
  });

  String type;
  bool isSelected;
  bool isSeen;
  VideoPlayerController? videoPlayerController;
}
