// import 'package:active_ecommerce_cms_demo_app/app_config.dart';
// import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
// import 'package:http/http.dart' as http;
// import 'package:active_ecommerce_cms_demo_app/data_model/slider_response.dart';
// import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
// class SlidersRepository {
//   Future<SliderResponse> getSliders() async {

//     String url =  ("${AppConfig.BASE_URL}/sliders");
//     final response =
//         await ApiRequest.get(url: url,
//           headers: {
//             "App-Language": app_language.$!,
//           },);
//     /*print(response.body.toString());
//     print("sliders");*/
//     return sliderResponseFromJson(response.body);
//   }

//   Future<SliderResponse> getBannerOneImages() async {

//     String url =  ("${AppConfig.BASE_URL}/banners-one");
//     final response =
//     await ApiRequest.get(url: url,
//       headers: {
//         "App-Language": app_language.$!,
//       },);
//     /*print(response.body.toString());
//     print("sliders");*/
//     return sliderResponseFromJson(response.body);
//   }

//   Future<SliderResponse> getBannerTwoImages() async {

//     String url =  ("${AppConfig.BASE_URL}/banners-two");
//     print(url.toString());
//     final response =
//     await ApiRequest.get(url: url,
//       headers: {
//         "App-Language": app_language.$!,
//       },);
//     /*print(response.body.toString());
//     print("sliders");*/
//     return sliderResponseFromJson(response.body);
//   }

//   Future<SliderResponse> getBannerThreeImages() async {

//     String url =  ("${AppConfig.BASE_URL}/banners-three");
//     final response =
//     await ApiRequest.get(url: url,
//       headers: {
//         "App-Language": app_language.$!,
//       },);
//     /*print(response.body.toString());
//     print("sliders");*/
//     return sliderResponseFromJson(response.body);
//   }

// }

import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/slider_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class SlidersRepository {
  Future<SliderResponse> getSliders() async {
    String url = ("${AppConfig.BASE_URL}/sliders");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    /*print(response.body.toString());
    print("sliders");*/
    return sliderResponseFromJson(response.body);
  }

  Future<SliderResponse> getBannerOneImages() async {
    String url = ("${AppConfig.BASE_URL}/banners-one");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    /*print(response.body.toString());
    print("sliders");*/
    return sliderResponseFromJson(response.body);
  }

  Future<SliderResponse> getBannerTwoImages() async {
    String url = ("${AppConfig.BASE_URL}/banners-two");
    print(url.toString());
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    /*print(response.body.toString());
    print("sliders");*/
    return sliderResponseFromJson(response.body);
  }

  Future<SliderResponse> getBannerThreeImages() async {
    String url = ("${AppConfig.BASE_URL}/banners-three");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    /*print(response.body.toString());
    print("sliders");*/
    return sliderResponseFromJson(response.body);
  }

  ///riaj
  Future<List<FlashDealResponseDatum>> fetchBanners() async {
    String url = ("${AppConfig.BASE_URL}/flash-deals");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
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
      throw Exception('Failed to load banners: Status code not 200');
    }
  }
}
