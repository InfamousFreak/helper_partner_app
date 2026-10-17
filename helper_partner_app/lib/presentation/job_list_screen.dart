    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'job_provider.dart';
    import 'job_detail_screen.dart';
    import '../services/analytics_service.dart';
    import '../data/job.dart';

    class JobListScreen extends ConsumerWidget {
    const JobListScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final jobsAsyncValue = ref.watch(jobsProvider);
        final searchQuery = ref.watch(searchQueryProvider);
        ref.listen<AsyncValue<List<Job>>>(jobsProvider, (prev, next) {
            next.whenData((jobs) => AnalyticsService().jobListViewed(jobs.length));
        });

        return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
            title: const Text('Assigned Jobs', style: TextStyle(fontWeight: FontWeight.w600)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                    hintText: 'Search jobs or companies...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                    ),
                ),
                ),
            ),
            ),
        ),
        body: jobsAsyncValue.when(
            data: (allJobs) {
            // Filter jobs based on the search query
            final jobs = allJobs.where((job) {
                final query = searchQuery.toLowerCase();
                return job.jobTitle.toLowerCase().contains(query) || 
                    job.companyName.toLowerCase().contains(query);
            }).toList();

            if (jobs.isEmpty) {
                return const Center(child: Text('No jobs found.', style: TextStyle(fontSize: 16)));
            }
            
            return RefreshIndicator(
                onRefresh: () async {
                ref.read(searchQueryProvider.notifier).state = ''; // Clear search on refresh
                return ref.refresh(jobsProvider.future);
                },
                child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
                        );
                        },
                        child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Expanded(
                                    child: Row(
                                    children: [
                                        if (job.isHot) 
                                        const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                        ),
                                        Expanded(
                                        child: Text(
                                            job.jobTitle,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        ),
                                    ],
                                    ),
                                ),
                                _buildStatusBadge(job.status),
                                ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                                job.companyName,
                                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                                children: [
                                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(job.location, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                const Spacer(),
                                Icon(Icons.payments_outlined, size: 16, color: Colors.green.shade600),
                                const SizedBox(width: 6),
                                Text(job.salary, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                            ),
                            ],
                        ),
                        ),
                    ),
                    );
                },
                ),
            );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(error.toString(), textAlign: TextAlign.center),
                ElevatedButton.icon(
                    onPressed: () => ref.refresh(jobsProvider.future),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                )
                ],
            ),
            ),
        ),
        );
    }

    Widget _buildStatusBadge(String status) {
        Color bgColor = status == 'COMPLETED' ? Colors.green.shade50 : 
                        status == 'IN_PROGRESS' ? Colors.orange.shade50 : Colors.blue.shade50;
        Color textColor = status == 'COMPLETED' ? Colors.green.shade700 : 
                        status == 'IN_PROGRESS' ? Colors.orange.shade800 : Colors.blue.shade800;

        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Text(
            status.replaceAll('_', ' '),
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        );
    }
    }