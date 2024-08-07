import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_audio_call/main.dart';
import 'package:video_audio_call/service/config.dart';


class VideoCallScreen extends StatefulWidget {
  final String channelId;
  final String token;
  final String isAudio;
  const VideoCallScreen({super.key, required this.channelId, required this.token, required this.isAudio});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

late RtcEngine videoEngine;

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    videoEngine = createAgoraRtcEngine();
    await videoEngine.initialize(RtcEngineContext(
      appId: videoAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    videoEngine.registerEventHandler(
      RtcEngineEventHandler(onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("local user ${connection.localUid} joined");
        setState(() {
          _localUserJoined = true;
        });
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        setState(() {
          _remoteUid = remoteUid;
        });
      }, onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        debugPrint("sdsd remote user $reason left channel");
        setState(() {
          _remoteUid = null;
          removeVideoData();
          Get.back();
        });
      }, onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      }, onConnectionLost: (RtcConnection connection) {
        debugPrint('  onConnectionLost  [onTokenPrivilegeWillExpire] connection: ${connection.toJson()}');
      }, onContentInspectResult: (ContentInspectResult connection) {
        debugPrint('  onContentInspectResult  [onTokenPrivilegeWillExpire] connection: ${connection.name}');
      }, onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        Get.back();
      }),
    );

    await videoEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    if (widget.isAudio == "false") {
      await videoEngine.enableVideo();
    }

    await videoEngine.startPreview();

    await videoEngine.joinChannel(
      token: widget.token,
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _dispose();
  }

  Future<void> _dispose() async {
    await videoEngine.leaveChannel();
    await videoEngine.release();
  }

  bool isMute = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          if (widget.isAudio == "false")
            Center(
              child: _remoteVideo(),
            ),
          if (widget.isAudio == "false")
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 150,
                height: 200,
                child: Center(
                  child: _localUserJoined
                      ? Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: videoEngine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            )
          else
            Container(
              height: MediaQuery.of(context).size.height,
              width:  MediaQuery.of(context).size.width,
              color: Colors.black.withOpacity(0.4),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height *0.3),
              child: Center(
                child: Container(
                  height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.black.withOpacity(0.3))
                    ),
                    child: Icon(Icons.person,size: 100,color: Colors.black.withOpacity(0.3),)),
              ),
            ),
          Positioned(
              bottom: 50,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: InkWell(
                        onTap: () {
                          videoEngine.switchCamera();
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.blue),
                          child: const Icon(
                            Icons.camera_front,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Center(
                      child: InkWell(
                        onTap: () {
                          videoEngine.leaveChannel();
                          videoEngine.release();
                          Get.back();
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Center(
                      child: InkWell(
                        onTap: () {
                          isMute = !isMute;
                          videoEngine.muteLocalAudioStream(isMute);
                          setState(() {});
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.blue),
                          child: Icon(
                            isMute ? Icons.mic_off : Icons.mic,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: videoEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelId),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}

leaveCall() async {
  await videoEngine.leaveChannel();
  await videoEngine.release();
}

removeVideoData() async {
  // final SharedPreferences sharePrefs = injector<SharedPreferences>();
  await storage.remove("channelName");
  await storage.remove("videoToken");
}
