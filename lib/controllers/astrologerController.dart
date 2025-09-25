import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/models/fastApi/AstrologerProfileModel.dart';
import 'package:get/get.dart';


class AstrologerController extends GetxController {
  final FastApiServices _apiService = FastApiServices();

  var astrologerProfile = Rxn<AstrologerProfile>();
  var isLoading = false.obs;

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getAstrologerById();
      astrologerProfile.value = AstrologerProfile.fromJson(response);
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
