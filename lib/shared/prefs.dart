import 'package:flutter/cupertino.dart';

class PrefsState {
  final bool showWaterDataGraphForMonth;
  final bool showSleepDataGraphForMonth;
  const PrefsState(
      {this.showWaterDataGraphForMonth, this.showSleepDataGraphForMonth});
}

class PrefNotifier with ChangeNotifier {
  PrefsState _currentPrefs = PrefsState(
      showSleepDataGraphForMonth: false, showWaterDataGraphForMonth: false);

  bool get showWaterDataGraphForMonth =>
      _currentPrefs.showWaterDataGraphForMonth;
  bool get showSleepDataGraphForMonth =>
      _currentPrefs.showSleepDataGraphForMonth;

  set showWaterDataGraphForMonth(bool newValue) {
    if (newValue == _currentPrefs.showWaterDataGraphForMonth) return;
    _currentPrefs = PrefsState(showWaterDataGraphForMonth: newValue);
    notifyListeners();
  }

  set showSleepDataGraphForMonth(bool newValue) {
    if (newValue == _currentPrefs.showSleepDataGraphForMonth) return;
    _currentPrefs = PrefsState(showSleepDataGraphForMonth: newValue);
    notifyListeners();
  }
}
