import 'package:get/get.dart';
import '../model/home_model.dart';

class HomeTuController extends GetxController {
  final Rx<TuHomeModel> state = TuHomeModel.placeholder().obs;
}
