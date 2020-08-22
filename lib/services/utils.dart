import 'package:water_recommender/model/waterIntake.dart';

class Utils {
  int getTotalIntakeTodayFromListOfIntakes(List<WaterIntake> intakes) {
    int amount = 0;
    if (intakes != null) {
      for (WaterIntake intake in intakes) {
        amount += intake.amount;
      }
      return amount;
    }
    return amount;
  }

  double getGoalAchievedPercent(List<WaterIntake> intakes, int goal) {
    int amount = getTotalIntakeTodayFromListOfIntakes(intakes);
    if (amount / goal < 1.0) {
      return amount / goal;
    }

    if (intakes == null) {
      return 0;
    }
    return 1;
  }
}
