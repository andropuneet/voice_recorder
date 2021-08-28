import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

class AudioBar {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  AudioPlayer _audioPlayer;

  AudioBar() {
    _init();
  }

  void _init() async {
    // initialize the song
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(1);
    // listen for changes in player state
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      final processingState = playerState;
      if (processingState == AudioPlayerState.PLAYING) {
        buttonNotifier.value = ButtonState.playing;
      } else if (processingState == AudioPlayerState.PAUSED) {
        buttonNotifier.value = ButtonState.paused;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
    // listen for changes in play position
    _audioPlayer.onAudioPositionChanged.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    // listen for changes in the total audio duration
    _audioPlayer.onDurationChanged.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play(Recording _recording) async {
    _audioPlayer.play(_recording.path, isLocal: true);
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    @required this.current,
    @required this.buffered,
    @required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }
