import 'package:get/get.dart';
import '../model/kategori_fasilitas_model.dart';

class KategoriFasilitasController extends GetxController {
  final RxList<KategoriFasilitasModel> items = KategoriFasilitasModel.dummyList().obs;
}