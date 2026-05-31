import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';

class AdminUserController extends GetxController {
  final UserService _userService;
  
  AdminUserController({UserService? userService})
      : _userService = userService ?? UserService();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final fetchedUsers = await _userService.getAll();
      users.assignAll(fetchedUsers);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _userService.delete(id);
      users.removeWhere((user) => user.id == id);
      Get.snackbar('Sukses', 'User berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus user: $e');
    }
  }
}
