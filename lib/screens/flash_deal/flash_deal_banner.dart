import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

// class BannerRepository {
//   Future<List<FlashDealResponseDatum>> fetchBanners() async {
//     String url = ("${AppConfig.BASE_URL}/flash-deals");
//     final response = await ApiRequest.get(
//       url: url,
//       headers: {
//         "App-Language": app_language.$!,
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       if (jsonData['data'] != null) {
//         return (jsonData['data'] as List)
//             .map((banner) => FlashDealResponseDatum.fromJson(banner))
//             .toList();
//       } else {
//         throw Exception('Failed to load banners: Data is null');
//       }
//     } else {
//       throw Exception('Failed to load banners: Status code not 200');
//     }
//   }
// }

class BannerRepository {
  Future<List<FlashDealResponseDatum>> fetchBanners() async {
    String url = ("${AppConfig.BASE_URL}/flash-deals");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$ ?? 'en', // Fallback to 'en' if null
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] != null) {
        return (jsonData['data'] as List)
            .map((banner) => FlashDealResponseDatum.fromJson(banner))
            .toList();
      } else {
        throw Exception('Failed to load banners: Data is null');
      }
    } else {
      throw Exception(
          'Failed to load banners: Status code ${response.statusCode}');
    }
  }
}

// class BannerProvider with ChangeNotifier {
//   List<FlashDealResponseDatum> _banners = [];
//   final BannerRepository _repository = BannerRepository();

//   List<FlashDealResponseDatum> get banners {
//     return [..._banners];
//   }

//   Future<void> loadBanners() async {
//     try {
//       final banners = await _repository.fetchBanners();
//       _banners = banners;
//       notifyListeners();
//     } catch (e) {
//       print('Error loading banners: $e');
//     }
//   }
// }

class BannerProvider with ChangeNotifier {
  List<FlashDealResponseDatum> _banners = [];
  late String _errorMessage;
  final BannerRepository _repository = BannerRepository();

  List<FlashDealResponseDatum> get banners {
    return [..._banners];
  }

  String get errorMessage => _errorMessage;

  Future<void> loadBanners() async {
    try {
      final banners = await _repository.fetchBanners();
      _banners = banners;
      _errorMessage = ''; // Clear error if banners load successfully
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading banners: $e';
      notifyListeners(); // Notify listeners so UI can respond to errors
    }
  }
}
