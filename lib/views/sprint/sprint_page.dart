import 'package:flutter/cupertino.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:scatter/views/sprint/sprint_timer_buttons.dart';

import './sprint_timer.dart';


class SprintPage extends StatefulWidget {
  @override
  _SprintPageState createState() => _SprintPageState();
}

class _SprintPageState extends State<SprintPage> with SingleTickerProviderStateMixin {
  final textController = TextEditingController();
  
  AnimationController animationController;
  bool started = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 0)
    )
    ..addStatusListener((status)  {
      if (status == AnimationStatus.completed) {
        FlutterRingtonePlayer.play(
          android: AndroidSounds.alarm,
          ios: IosSounds.alarm,
          asAlarm: true
        );
        // May need to wrap this in Future.delayed(Duration.zero, ...)
        // if something goes wrong later...
        _createDialog(context);
        _resetTimer();
      }
    });
  }

  _resetTimer() {
    setState(() {
      animationController.reset();
      started = false;
    });
  }

  _onTimerDurationChanged(Duration duration) {
    setState(() {
      animationController.duration = duration;
    });
  }

  _onCancelPressed() {
    _resetTimer();
  }

  _onStartPressed() {
    if (!started) {
      setState(() {
        started = true;
      });
    } 
    if (animationController.isAnimating) {
      animationController.stop();
    } else {
      animationController.forward();
    }
  }

  _onSubmitWordCount() {
    textController.text = "";
  }

  _createDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Sprint Finished!"),
          content: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: CupertinoTextField(
              controller: textController,
              placeholder: "Word count",
              keyboardType: TextInputType.number,
            )
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Discard"),
              onPressed: () => Navigator.pop(context),
              isDestructiveAction: true,
            ),
            CupertinoDialogAction(
              child: Text("Submit"),
              onPressed: () {
                _onSubmitWordCount();
                Navigator.pop(context);
              }
            )
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: FractionalOffset.center,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: started ? SprintTimer(
                  controller: animationController
                ) : CupertinoTimerPicker(
                  initialTimerDuration: animationController.duration,
                  onTimerDurationChanged: _onTimerDurationChanged,
                )
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: SprintTimerButtons(
              started: started,
              controller: animationController,
              onCancelPressed: _onCancelPressed,
              onStartPressed: _onStartPressed,
            )
          ),
        ],
      )
    );
  }
}

