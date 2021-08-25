import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:rxdart/subjects.dart';

class RecorderBloc {
  Stream<Recording> _recordingListStream = Stream.empty();

  BehaviorSubject<Recording> _recordingListSink =
  BehaviorSubject<Recording>();

  Stream<Recording> get recordingListStream => _recordingListStream;

  Sink<Recording> get recordingListSink => _recordingListSink;

  Stream<dynamic> _scaleStream = Stream.empty();

  BehaviorSubject<dynamic> _scaleSink =
  BehaviorSubject<dynamic>();

  Stream<dynamic> get scaleStream => _scaleStream;

  Sink<dynamic> get scaleSink => _scaleSink;

  List<Recording> recordingList = List();

  RecorderBloc(){
    _recordingListStream = _recordingListSink.asBroadcastStream();
    _scaleStream = _scaleSink.asBroadcastStream();
  }


  addRecording(Recording _currentRecording){
    recordingList.add(_currentRecording);
    recordingListSink.add(_currentRecording);
  }

  refreshRecording(){
    recordingList.clear();
    recordingListSink.add(null);
  }

  dispose() {
    _recordingListSink.close();
    _scaleSink.close();
  }
}