import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'job.dart';

class ApiService {
    static const String baseUrl = 'http://localhost:3000';
    final http.Client client;

    ApiService({http.Client? client}) : client = client ?? http.Client();

    Future<List<Job>> fetchJobs() async {
        try {
            final response = await client.get(Uri.parse('$baseUrl/jobs')).timeout(const Duration(seconds: 10));

            if (response.statusCode == 200) {
                final List<dynamic> body = jsonDecode(response.body);
                return body.map((dynamic item) => Job.fromJson(item)).toList();
            } else {
                throw Exception('Failed to load jobs (Status : ${response.statusCode})');
            }
        } on TimeoutException {
            throw Exception('Request timed out. Please check your network.');
        } on SocketException {
            throw Exception('No internet connection / Server unreachable.');
        }
    }

    Future<Job> updateJobStatus(String id, String newStatus) async {
        try {
            final response = await client.patch(Uri.parse('$baseUrl/jobs/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'status': newStatus}),).timeout(const Duration(seconds: 10));
            if (response.statusCode == 200) {
                return Job.fromJson(jsonDecode(response.body));
            } else {
                throw Exception('Failed to update status');
            }
        } on TimeoutException {
            throw Exception('Request timed out while updating status.');
        } on SocketException {
            throw Exception('Network error during status update.');
        }
    }
}