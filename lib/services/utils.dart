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
}
