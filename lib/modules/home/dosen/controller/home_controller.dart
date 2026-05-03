import 'package:get/get.dart';
import '../model/home_model.dart';

class HomeDosenController extends GetxController {
  final Rx<DosenHomeModel> state = DosenHomeModel.placeholder().obs;
}
