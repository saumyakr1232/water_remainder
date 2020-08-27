import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/utils.dart';

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
