import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

import 'audio_bar_widget.dart';

class AudioListItem extends StatefulWidget {
  final int index;
  final List<Recording> recordingList;
  final dynamic animation;
  AudioListItem({Key key,this.recordingList,this.index,this.animation}) : super(key: key);

  @override
  _AudioListItemState createState() => _AudioListItemState();
}

class _AudioListItemState extends State<AudioListItem> {

  @override
  Widget build(BuildContext context) {
    AudioBar _audioBar = AudioBar();
    return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset(0, 0),
        ).animate(CurvedAnimation(
            parent: widget.animation,
            curve: Curves.easeIn,
            reverseCurve: Curves.easeInOut)),
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Row(
                      children: [
                        ValueListenableBuilder<ButtonState>(
                          valueListenable: _audioBar.buttonNotifier,
                          builder: (_, value, __) {
                            switch (value) {
                              case ButtonState.loading:
                                return Container(
                                  margin: EdgeInsets.all(8.0),
                                  width: 32.0,
                                  height: 32.0,
                                  child:
                                  CircularProgressIndicator(),
                                );
                              case ButtonState.paused:
                                return IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  iconSize: 32.0,
                                  onPressed: () {
                                    _audioBar
                                        .play(widget.recordingList[widget.index]);
                                  },
                                );
                              case ButtonState.playing:
                                return IconButton(
                                  icon: Icon(Icons.pause),
                                  iconSize: 32.0,
                                  onPressed: _audioBar.pause,
                                );
                            }
                            return Container(
                              margin: EdgeInsets.all(8.0),
                              width: 32.0,
                              height: 32.0,
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                        ValueListenableBuilder<ProgressBarState>(
                          valueListenable:
                          _audioBar.progressNotifier,
                          builder: (_, value, __) {
                            return Expanded(
                                child: ProgressBar(
                                  progress: value.current,
                                  buffered: value.buffered,
                                  thumbColor: Colors.indigo,
                                  thumbRadius: 8,
                                  total: value.total,
                                  timeLabelLocation:
                                  TimeLabelLocation.below,
                                  onSeek: _audioBar.seek,
                                ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  radius: 20,
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
        ));;
  }
}