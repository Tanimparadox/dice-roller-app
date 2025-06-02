import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

final randomizer = Random();

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});
  @override
  State<DiceRoller> createState() {
    return _DiceRollerState();
  }
}

class _DiceRollerState extends State<DiceRoller> {
  final FlutterTts flutterTts = FlutterTts();
  int rollCount = 0;
  int sixCount = 0;
  int selectedDuration = 10; //default duration in seconds
  int remainingTime = 10; // for countdown
  bool isGameRunning = false; //now flag to track game state
  Timer? gameTimer;
  Timer? countdownTimer;

  var currentDiceRoll = 2;

  void rollDice() {
    if (!isGameRunning) return;
    setState(() {
      currentDiceRoll = randomizer.nextInt(6) + 1;
      rollCount++;
      if (currentDiceRoll == 6) {
        sixCount++;
      }
    });
  }

  // method to start the game timer
  void startGameTimer() {
    gameTimer?.cancel(); //cancle existing timer if any
    countdownTimer?.cancel();

    setState(() {
      rollCount = 0;
      sixCount = 0;
      remainingTime = selectedDuration;
      isGameRunning = true; // game has started
    });

    //countdown time every second
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime--;
      });
      //speak the number
      flutterTts.speak(remainingTime.toString());

      if (remainingTime == 0) {
        timer.cancel(); //stop countdown
      }
    });
    //main game timer
    gameTimer = Timer(Duration(seconds: selectedDuration), () {
      setState(() {
        isGameRunning = false; //stop the game
      });
      showResultsDialog();
    });
  }

  // a dialog method
  void showResultsDialog() {
    countdownTimer?.cancel(); //stop countdown when dialog shows

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "🎉 Congratulations!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "⏰ Time's Up!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "🎲 You rolled the dice $rollCount times\n"
                  "🎯 Number of 6s: $sixCount",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    rollCount = 0;
                    sixCount = 0;
                    remainingTime = selectedDuration;
                  });
                },
                child: Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.6);
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        backgroundColor: const Color(0xFF2193b0),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //dropdownbutton here
              DropdownButton<int>(
                value: selectedDuration,
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                items:
                    [10, 20, 30, 60].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value seconds"),
                      );
                    }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedDuration = newValue!;
                    remainingTime = newValue;
                  });
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (!isGameRunning) startGameTimer();
                },
                child: Text("Start Game"),
              ),
              //countdown display
              Text(
                "Time left: $remainingTime s",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Image.asset(
                  'assets/images/dice-$currentDiceRoll.png',
                  key: ValueKey(currentDiceRoll),
                  width: 250,
                ),
              ),
              const SizedBox(height: 70),
              ElevatedButton(
                onPressed: isGameRunning ? rollDice : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 55),
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black45,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.casino, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Play Dice',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // child: Text(
                //   'Play Dice',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
