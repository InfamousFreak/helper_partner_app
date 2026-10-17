import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void jobListViewed(int jobCount) {
    _analytics.logEvent(
      name: 'job_list_viewed',
      parameters: {'job_count': jobCount},
    );
  }

  void jobDetailsViewed(String jobStatus) {
    _analytics.logEvent(
      name: 'job_details_viewed',
      parameters: {'job_status': jobStatus},
    );
  }

  void jobStatusUpdated(String newStatus) {
    _analytics.logEvent(
      name: 'job_status_updated',
      parameters: {'job_status': newStatus},
    );
  }
}