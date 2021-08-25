import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qoohoo_audio_recorder/bloc/recorder_bloc.dart';
import 'package:qoohoo_audio_recorder/widgets/audio_list_item.dart';
import 'package:vibrate/vibrate.dart';

class AudioChatScreen extends StatefulWidget {
  AudioChatScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AudioChatScreenState createState() => _AudioChatScreenState();
}

class _AudioChatScreenState extends State<AudioChatScreen>
    with SingleTickerProviderStateMixin {
  var screenHeight;
  AudioCache _audioCache;
  FlutterAudioRecorder _recorder;
  Recording _recording;
  List<Recording> recordingList = List();
  Timer _t;
  Widget _buttonIcon = Icon(Icons.do_not_disturb_on);
  double _scale = 0.0;
  AnimationController _controller;
  RecorderBloc recorderBloc;
  var _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    recorderBloc = RecorderBloc();
    recorderBloc.recordingListStream.listen((event) {
      if (event != null) {
        recordingList.add(event);
        _listKey.currentState.insertItem(recordingList.length - 1);
      }
    });
    _audioCache = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        recorderBloc.scaleSink.add(1);
      });
    Future.microtask(() {
      _prepare();
    });
  }

  Future _init() async {
    String customPath = '/flutter_audio_recorder_';
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString();
    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
    } else {
      // permission not available toast
    }
  }

  Future _startRecording() async {
    await _prepare();
    await _recorder.start();
    var current = await _recorder.current();
    _recording = current;
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    // _t.cancel();
    _recording = result;
    recorderBloc.addRecording(_recording);
  }

  // void _opt() async {
  //   switch (_recording.status) {
  //     case RecordingStatus.Initialized:
  //       {
  //         await _startRecording();
  //         break;
  //       }
  //     case RecordingStatus.Recording:
  //       {
  //         await _stopRecording();
  //         break;
  //       }
  //     case RecordingStatus.Stopped:
  //       {
  //         await _prepare();
  //         break;
  //       }
  //
  //     default:
  //       break;
  //   }
  //
  //   // 刷新按钮
  //   setState(() {
  //     _buttonIcon = _playerIcon(_recording.status);
  //   });
  // }
  //
  // Widget _playerIcon(RecordingStatus status) {
  //   switch (status) {
  //     case RecordingStatus.Initialized:
  //       {
  //         return Icon(Icons.fiber_manual_record);
  //       }
  //     case RecordingStatus.Recording:
  //       {
  //         return Icon(Icons.stop);
  //       }
  //     case RecordingStatus.Stopped:
  //       {
  //         return Icon(Icons.replay);
  //       }
  //     default:
  //       return Icon(Icons.do_not_disturb_on);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: 15, right: 15, top: 15),
            constraints: BoxConstraints(minHeight: screenHeight - 100),
            child: AnimatedList(
              key: _listKey,
              initialItemCount: recordingList.length,
              padding: EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index, animation) {
                return AudioListItem(recordingList: recordingList,index: index,animation:animation);
              },
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
            ),
          )),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 150),
            child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 15,
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  semanticContainer: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Hold to talk",
                            style: TextStyle(color: Colors.grey),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: StreamBuilder(
                              builder: (context, snapshot) {
                                _scale = 1.2 - _controller.value;
                                return Transform.scale(
                                  scale: _scale,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    radius: 40,
                                    child: Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                              stream: recorderBloc.scaleStream,
                              initialData: 1,
                            ),
                            onLongPressStart: (_) {
                              Vibrate.feedback(FeedbackType.medium);
                              _controller.reverse();
                              _startRecording();
                            },
                            onLongPressEnd: (_) {
                              _audioCache.play('beep.wav',
                                  volume: 0.1, mode: PlayerMode.LOW_LATENCY);
                              _controller.forward();
                              _stopRecording();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
