import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';

class FAQData {
  final String? id;
  final String? question;
  final String? answer;

  FAQData({this.id, this.question, this.answer});

  factory FAQData.fromMap(Map<String, dynamic> json) => FAQData(
        id: json["_id"],
        question: json["question"],
        answer: json["answer"],
      );
}

class FAQRepository {
  final ApiClient _apiClient = locator<ApiClient>();

  Future<Result<List<FAQData>, Failure>> getFAQs() async {
    final result = await _apiClient.get(
      ApiUrl.faqs,
      queryParameters: {'page': 1, 'limit': 100},
    );

    return result.when(
      success: (data) {
        final List list = data['data']?['data'] ?? [];
        return Success(list.map((x) => FAQData.fromMap(x)).toList());
      },
      failure: (failure) => Error(failure),
    );
  }
}
