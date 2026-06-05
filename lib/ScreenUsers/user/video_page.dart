import 'package:app_flutter/ScreenUsers/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideosScreen extends StatefulWidget {
  final String courseName;
  final int courseId;
  final VoidCallback onBack;

  const VideosScreen({
    super.key,
    required this.courseName,
    required this.courseId,
    required this.onBack,
  });

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  VideoPlayerController? controller;
  String? currentVideoUrl;
  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      final data = await videoService.getVideos(widget.courseId);

      if (!mounted) return;

      setState(() {
        videos = data ?? [];
      });
    } catch (e) {
      print("Error loading videos: $e");
    }
  }

  bool isLoading = false;

  List<dynamic> videos = [];

  final VideoService videoService = VideoService();

  Future<void> playVideo(String url) async {
    setState(() {
      isLoading = true;
    });

    currentVideoUrl = url;

    final oldController = controller;
    controller = null;
    setState(() {});

    await oldController?.dispose();

    final newController = VideoPlayerController.networkUrl(Uri.parse(url));

    controller = newController;

    await newController.initialize();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    await newController.play();
  }

  void togglePlayPause() {
    if (controller == null || !controller!.value.isInitialized) return;

    setState(() {
      controller!.value.isPlaying ? controller!.pause() : controller!.play();
    });
  }

  void forward() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final pos = await controller!.position;
    if (pos != null) {
      controller!.seekTo(pos + const Duration(seconds: 10));
    }
  }

  void rewind() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final pos = await controller!.position;
    if (pos != null) {
      controller!.seekTo(pos - const Duration(seconds: 10));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> closeVideoPage() async {
    await controller?.pause();
    await controller?.dispose();
    controller = null;

    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = controller != null && controller!.value.isInitialized;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDBC602),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await controller?.pause();
            await controller?.dispose();
            controller = null;

            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text("كورسات ${widget.courseName}"),
      ),

      body: Column(
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else if (isReady)
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!),
                ),

                Positioned(
                  top: 170,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () async {
                      final currentPos = controller!.value.position;

                      await controller?.pause();

                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenVideo(
                            videoUrl: currentVideoUrl!,
                            startPosition: currentPos,
                          ),
                        ),
                      ).then((_) {
                        controller?.play();
                      });
                    },
                  ),
                ),
              ],
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("اضغط على درس لتشغيل الفيديو"),
            ),

          if (isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: VideoProgressIndicator(
                controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          SizedBox(height: 5),

          if (isReady)
            Container(
              height: 80,
              width: 355,
              decoration: BoxDecoration(
                color: const Color.fromARGB(191, 146, 146, 146),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color.fromARGB(255, 9, 103, 255),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🔹 الأزرار بالنص
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Color.fromARGB(255, 255, 255, 255),
                        icon: const Icon(Icons.replay_10),
                        onPressed: rewind,
                      ),
                      IconButton(
                        iconSize: 60,
                        color: const Color.fromARGB(255, 0, 149, 248),
                        icon: Icon(
                          controller!.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        onPressed: togglePlayPause,
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.forward_10),
                        onPressed: forward,
                      ),
                    ],
                  ),

                  // 🔹 النص على الجنب (يمين ثابت)
                  Positioned(
                    right: 18,
                    child: ValueListenableBuilder(
                      valueListenable: controller!,
                      builder: (context, VideoPlayerValue value, child) {
                        String format(Duration d) {
                          String twoDigits(int n) =>
                              n.toString().padLeft(2, '0');

                          final minutes = twoDigits(d.inMinutes.remainder(60));
                          final seconds = twoDigits(d.inSeconds.remainder(60));

                          return "$minutes:$seconds";
                        }

                        return Text(
                          "${format(value.position)} / ${format(value.duration)}",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 253, 253),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final videoFile = videos[index]["video"] ?? "";

                      if (videoFile.isEmpty) return;

                      final fileName = videoFile
                          .split('/')
                          .last; // مهم لو مسار كامل

                      final fullUrl =
                          "http://127.0.0.1:8000/api/stream/$fileName";

                      playVideo(fullUrl);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              videos[index]["title"]!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideo extends StatefulWidget {
  final String videoUrl;
  final Duration? startPosition;

  const FullScreenVideo({
    super.key,
    required this.videoUrl,
    this.startPosition,
  });

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController controller;
  bool showControls = true;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) async {
        if (!mounted) return;

        if (widget.startPosition != null) {
          await controller.seekTo(widget.startPosition!);
        }

        setState(() {});
        controller.play();
      });
  }

  @override
  void dispose() {
    // ❌ لا تعمل dispose هنا لأنه نفس controller الرئيسي
    super.dispose();
  }

  void togglePlay() {
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  void forward() async {
    final pos = await controller.position;
    if (pos != null) {
      controller.seekTo(pos + const Duration(seconds: 10));
    }
  }

  void rewind() async {
    final pos = await controller.position;
    if (pos != null) {
      controller.seekTo(pos - const Duration(seconds: 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),

            if (showControls)
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            if (showControls)
              Positioned(
                bottom: 40,
                left: 10,
                right: 10,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                          ),
                          onPressed: rewind,
                        ),
                        IconButton(
                          iconSize: 60,
                          color: Colors.white,
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          ),
                          onPressed: togglePlay,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                          ),
                          onPressed: forward,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
