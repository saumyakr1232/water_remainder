import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/utils.dart';
import 'package:water_recommender/shared/prefs.dart';

class AmountCounter extends StatefulWidget {
  final bool isSleep;
  AmountCounter(this.isSleep);
  @override
  _AmountCounterState createState() => _AmountCounterState(isSleep);
}

class _AmountCounterState extends State<AmountCounter> {
  final bool isSleep;
  int _amount;
  bool _shoudCount;

  _AmountCounterState(this.isSleep);

  Future setAmount(int intake) async {
    while (_amount < intake && _shoudCount) {
      setState(() {
        _amount += 1;
      });
      Utils.setAmount(_amount, isSleep);

      await Future.delayed(Duration(microseconds: 5000));
    }
    while (intake < _amount && _shoudCount) {
      setState(() {
        _amount -= 1;
      });
      Utils.setAmount(_amount, isSleep);
      await Future.delayed(Duration(microseconds: 5000));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _shoudCount = false;
  }

  @override
  void initState() {
    super.initState();
    _amount = Utils().getAmount(isSleep);
    _shoudCount = true;
  }

  @override
  Widget build(BuildContext context) {
//    print("Called form _AmountCounterState");
    final List<SleepData> naps = Provider.of<List<SleepData>>(context);
    final List<WaterIntake> intakes = Provider.of<List<WaterIntake>>(context);
    setAmount(isSleep
        ? Utils().getTotalSleepToday(naps)
        : Utils().getTotalIntakeToday(intakes));
    return Text(
      isSleep ? (_amount / 60).round().toString() : _amount.toString(),
      style: TextStyle(
          color: isSleep ? Colors.grey.shade800 : Colors.indigo.shade800,
          fontSize: 60.0),
    );
  }
}

class CustomToggleButton extends StatefulWidget {
  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  List<bool> _isSelected = [true, false];
  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PrefNotifier>(context);

    return ToggleButtons(
      children: [
        Padding(
          child: Text("Past 7 days"),
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        ),
        Padding(
          child: Text("Last month"),
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        ),
      ],
      borderColor: Colors.indigo.shade400,
      disabledBorderColor: Colors.indigo.shade400,
      selectedBorderColor: Colors.indigo.shade400,
      fillColor: Colors.indigo.shade400,
      color: Colors.indigo.shade400,
      selectedColor: Colors.white,
      isSelected: _isSelected,
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
      onPressed: (int index) {
        setState(() {
          _isSelected = _isSelected.reversed.toList();
          prefs.showWaterDataGraphForMonth = !prefs.showWaterDataGraphForMonth;
        });
      },
    );
  }
}
