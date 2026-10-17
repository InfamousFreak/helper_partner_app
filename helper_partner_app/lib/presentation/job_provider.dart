    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import '../data/job.dart';
    import '../data/api_service.dart';
    import 'package:flutter_riverpod/legacy.dart';

    final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

    final jobsProvider = FutureProvider<List<Job>>((ref) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.fetchJobs();
    });

    // NEW: Tracks the current search query for the quality improvement feature
    final searchQueryProvider = StateProvider<String>((ref) => '');