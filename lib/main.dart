import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List practise for Waver',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListOfAudioPlayers(), //MyList(),
    );
  }
}

class MyList extends StatefulWidget {
  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  int selectedIndex;

  onPressed(int i) {
    setState(() {
      selectedIndex = i;
    });
  }


  List model = [
    {
      'title': 'item',
    },
    {
      'title': 'item2',
    },
    {
      'title': 'item3',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyItem(0, (selectedIndex == 0) ? true : false, onPressed, model[0]),
      MyItem(1, (selectedIndex == 1) ? true : false, onPressed, model[1]),
      MyItem(2, (selectedIndex == 2) ? true : false, onPressed, model[2]),
    ],);
  }
}

class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  int _selectedIndex;

  onPressed(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  _checkSelected(int index) {
    if(_selectedIndex == index){
      return true;
    } else {
      return false;
    }
  }

  List model = [
    {
      'title': 'item',
    },
    {
      'title': 'item2',
    },
    {
      'title': 'item3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: model.length,
      itemBuilder: (context, index) {
        return MyItem(index, _checkSelected(index), onPressed, model[index]);
      }
    );
  }
}

class MyItem extends StatefulWidget {
  final int index;
  final bool selected;
  final Function onPressed;
  final Map dataModel;

  MyItem(this.index, this.selected, this.onPressed, this.dataModel);

  @override
  _MyItemState createState() => _MyItemState();
}

class _MyItemState extends State<MyItem> {
  Color color = Colors.blue;

  @override
  void didUpdateWidget(oldwidget) {
    color = widget.selected ? Colors.amber : Colors.blue;
    super.didUpdateWidget(oldwidget);
  }

  onPressed() {
    // if currently active, then send a large index to make the parent return false to all. 
    // Because 999999 matches with no instances' index.
    if(widget.selected) {
      widget.onPressed(999999);
    } else {
      widget.onPressed(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: color,
        child: Text(widget.dataModel['title']),
        onPressed: onPressed,
      );
  }
}

class ListOfAudioPlayers extends StatefulWidget {
  @override
  _ListOfAudioPlayersState createState() => _ListOfAudioPlayersState();
}

class _ListOfAudioPlayersState extends State<ListOfAudioPlayers> {
  List<Map> model = [{'title': 'item',},{'title': 'item2',},{'title': 'item3',},];
  
  int _selectedIndex;

  onPressed(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  _checkSelected(int index) {
    if(_selectedIndex == index){
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: model.length,
      itemBuilder: (context, index) {
        return AudioPlayer(index, _checkSelected(index), onPressed, model[index]);
      }
    );
  }

}

class AudioPlayer extends StatefulWidget {
  final int index;
  final bool selected;
  final Function onPressed;
  final Map dataModel;

  AudioPlayer(this.index, this.selected, this.onPressed, this.dataModel);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  // Audio
  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  Codec _codec = Codec.aacADTS;
  bool _isAudioPlayer = false;

  // UI
  Color color = Colors.blue;

    // Slider
    StreamSubscription _playerSubscription;
    double sliderCurrentPosition = 0.0;
    double maxDuration = 1.0;

  @override
  void didUpdateWidget(oldwidget) {
    color = widget.selected ? Colors.amber : Colors.blue;
    widget.selected ? startPlayer() : stopPlayer();
    print('player with index ${widget.index} selection status is ${widget.selected}');
    super.didUpdateWidget(oldwidget);
  }

  onPressed() {
    // if currently active, then send a large index to make the parent return false to all. 
    // Because 999999 matches with no instances' index.
    if(widget.selected) {
      widget.onPressed(999999);
    } else {
      widget.onPressed(widget.index);
    }
  }

  // Logic Audio
  Future<void> init() async {
    await playerModule.closeAudioSession();
    await playerModule.openAudioSession(
      focus: AudioFocus.requestFocusTransient, 
      category: SessionCategory.playAndRecord, 
      mode: SessionMode.modeDefault, 
      device: AudioDevice.speaker
    );
    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  @override
  void initState() {
    super.initState();
    //init();
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    releaseFlauto();
  }

   Future<void> startPlayer() async {
    try {
      await init();
      String audioFilePath;
      audioFilePath = 'https://firebasestorage.googleapis.com/v0/b/waverapp-b7c34.appspot.com/o/audio%2Ffollow%20me%20at%20%40fancydavide%20omg%20zo%20fancy?alt=media&token=cdd27dc3-ecbc-43af-a348-771f41e01fc5'; // model.audio
      
      // Check whether the user wants to use the audio player features
      if (_isAudioPlayer) {
        final track = Track(
          trackPath: audioFilePath,
          trackTitle: "This is a record",
          trackAuthor: "from flutter_sound",
        );
        await playerModule.startPlayerFromTrack(track,
            /*canSkipForward:true, canSkipBackward:true,*/
            whenFinished: () {
          print('I hope you enjoyed listening to this song');
          setState(() {});
        }, onSkipBackward: () {
          print('Skip backward');
        }, onSkipForward: () {
          print('Skip forward');
        }, onPaused: (bool b) {
          if (b)
            playerModule.pausePlayer();
          else
            playerModule.resumePlayer();
        });
      } else {
        if (audioFilePath != null) {
          await playerModule.startPlayer(
              fromURI: audioFilePath,
              codec: _codec,
              whenFinished: () {
                print('Play finished');
                setState(() {
                  // Set a large index to make the parent return false to all. 
                  // Because 999999 matches with no instances' index.
                  // Bit of a hack.
                  widget.onPressed(999999);
                });
              });
        }
      }
      _addListeners();
      print('startPlayer');
      // await flutterSoundModule.setVolume(1.0);
    } catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  Future<void> stopPlayer() async {
    try {
      await playerModule.stopPlayer();
      print('stopPlayer');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } catch (err) {
      print('error: $err');
    }
    this.setState(() {
      //this._isPlaying = false;
    });
  }

  // Logic Slider
    void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onProgress.listen((e) {
      if (e != null) {
        maxDuration = e.duration.inMilliseconds.toDouble();
        if (maxDuration <= 0) maxDuration = 0.0;

        sliderCurrentPosition = min(e.position.inMilliseconds.toDouble(), maxDuration);
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }
        setState(() {
        
        });

        //DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds, isUtc: true);
        // String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        // this.setState(() {
        //   this._playerTxt = txt.substring(0, 8);
        // });
      }
    });
  }

  void seekToPlayer(int milliSecs) async {
    await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
    print('seekToPlayer');
  }

  @override
  Widget build(BuildContext context) {

    final playerSlider = Container(
        height: 56.0,
        child: Slider(
            value: min(sliderCurrentPosition, maxDuration),
            min: 0.0,
            max: maxDuration,
            onChanged: (double value) async {
              await playerModule.seekToPlayer(Duration(milliseconds: value.toInt() ));
            },
            divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()
            )
        );

    return RaisedButton(
        color: color,
        child: Column( children: [
          Text(widget.dataModel['title']),
          playerSlider,
        ],),
        onPressed: onPressed,
      );
  }
}