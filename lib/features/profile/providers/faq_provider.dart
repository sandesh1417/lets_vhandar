import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/features/profile/data/faq_repository.dart';

final faqRepositoryProvider = Provider((ref) => FAQRepository());

final faqProvider = FutureProvider<List<FAQData>>((ref) async {
  final repository = ref.watch(faqRepositoryProvider);
  final result = await repository.getFAQs();
  
  return result.when(
    success: (faqs) => faqs,
    failure: (failure) => throw failure,
  );
});
