import 'package:video_player/video_player.dart';

class Video {
  String id;
  String user;
  String userPic;
  String videoTitle;
  String songName;
  String likes;
  String comments;
  String url;
  int loopCount = 0;
  bool isAuthentic;
  bool reachedThreshold = false;
  bool reachedVibeCheckThreshold = false;
  bool get isDeepDive => loopCount >= 1 && reachedThreshold;
  String? vibeCheckResult;
  String? topComment;
  String? suggestedSearch; // 2026 Trend: Curiosity Detours
  List<String> keywords = []; 
  Function? onLoop;
  Function? onThresholdReached;
  Function? onVibeCheckTriggered;

  VideoPlayerController? controller;

  Video(
      {required this.id,
      required this.user,
      required this.userPic,
      required this.videoTitle,
      required this.songName,
      required this.likes,
      required this.comments,
      required this.url,
      this.loopCount = 0,
      this.isAuthentic = false,
      this.topComment,
      this.suggestedSearch,
      this.keywords = const [],
      this.onLoop});

  Video.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        user = json['user'],
        userPic = json['user_pic'],
        videoTitle = json['video_title'],
        songName = json['song_name'],
        likes = json['likes'],
        comments = json['comments'],
        url = json['url'],
        isAuthentic = json['is_authentic'] ?? false,
        topComment = json['top_comment'],
        suggestedSearch = json['suggested_search'],
        keywords = List<String>.from(json['keywords'] ?? []),
        loopCount = 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user;
    data['user_pic'] = this.userPic;
    data['video_title'] = this.videoTitle;
    data['song_name'] = this.songName;
    data['likes'] = this.likes;
    data['comments'] = this.comments;
    data['url'] = this.url;
    data['is_authentic'] = this.isAuthentic;
    data['top_comment'] = this.topComment;
    data['suggested_search'] = this.suggested_search;
    data['keywords'] = this.keywords;
    return data;
  }

  Future<Null> loadController() async {
    controller = VideoPlayerController.network(url);
    await controller?.initialize();
    controller?.setLooping(true);
    
    Duration lastPos = Duration.zero;
    controller?.addListener(() {
      if (controller != null && controller!.value.isPlaying) {
        Duration currentPos = controller!.value.position;
        
        if (controller!.value.duration.inMilliseconds > 0) {
          double progress = currentPos.inMilliseconds / controller!.value.duration.inMilliseconds;
          
          if (progress >= 0.7 && !reachedThreshold) {
            reachedThreshold = true;
            if (onThresholdReached != null) onThresholdReached!();
          }

          if (progress >= 0.85 && !reachedVibeCheckThreshold && vibeCheckResult == null) {
            reachedVibeCheckThreshold = true;
            if (onVibeCheckTriggered != null) onVibeCheckTriggered!();
          }
        }

        if (currentPos < lastPos) {
          loopCount++;
          reachedThreshold = false;
          reachedVibeCheckThreshold = false;
          if (onLoop != null) onLoop!();
        }
        lastPos = currentPos;
      }
    });
  }
}