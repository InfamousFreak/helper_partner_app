    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import '../data/job.dart';
    import 'job_provider.dart';
    import '../services/analytics_service.dart';

    class JobDetailScreen extends ConsumerStatefulWidget {
    final Job job;

    const JobDetailScreen({super.key, required this.job});

    @override
    ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
    }

    class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
    bool _isLoading = false;
    late String _currentStatus;

    @override
    void initState() {
        super.initState();
        _currentStatus = widget.job.status;
        AnalyticsService().jobDetailsViewed(widget.job.status);
    }

    Future<void> _updateStatus(String newStatus) async {
        setState(() => _isLoading = true);
        try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.updateJobStatus(widget.job.id, newStatus);
        AnalyticsService().jobStatusUpdated(newStatus);
        
        setState(() {
            _currentStatus = newStatus;
            _isLoading = false;
        });
        
        ref.invalidate(jobsProvider);
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Job status updated successfully!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green.shade700,
            ),
            );
        }
        } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.red.shade700),
            );
        }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.w600)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
        ),
        body: SafeArea(
            child: Column(
            children: [
                Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (widget.job.isHot)
                        Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Icon(Icons.local_fire_department, size: 16, color: Colors.orange.shade800),
                                const SizedBox(width: 4),
                                Text('High Priority', style: TextStyle(color: Colors.orange.shade900, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                            ),
                        ),
                        Text(
                        widget.job.jobTitle,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                        widget.job.companyName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow(Icons.location_on_outlined, 'Location', widget.job.location),
                        const Divider(height: 32),
                        _buildDetailRow(Icons.work_outline, 'Job Type', widget.job.jobType),
                        const Divider(height: 32),
                        _buildDetailRow(Icons.payments_outlined, 'Salary', widget.job.salary),
                        const Divider(height: 32),
                        _buildDetailRow(Icons.psychology_outlined, 'Experience', widget.job.experience),
                        const Divider(height: 32),
                        _buildDetailRow(Icons.info_outline, 'Status', _currentStatus.replaceAll('_', ' ')),
                        
                        if (widget.job.skills.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Text('Required Skills', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.job.skills.map((skill) => Chip(
                            label: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            )).toList(),
                        ),
                        ],

                        if (widget.job.description.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Text('Job Description', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                            widget.job.description,
                            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                        ),
                        ],
                    ],
                    ),
                ),
                ),
                
                // Bottom Action Button fixed at the bottom of the screen
                if (_currentStatus != 'COMPLETED')
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: _currentStatus == 'ASSIGNED' ? Colors.teal : Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        ),
                        onPressed: _isLoading ? null : () {
                        _updateStatus(_currentStatus == 'ASSIGNED' ? 'IN_PROGRESS' : 'COMPLETED');
                        },
                        child: _isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _currentStatus == 'ASSIGNED' ? 'Mark as In Progress' : 'Mark as Completed',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                    ),
                ),
            ],
            ),
        ),
        );
    }

    Widget _buildDetailRow(IconData icon, String label, String value) {
        return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Icon(icon, color: Colors.grey.shade500, size: 24),
            const SizedBox(width: 16),
            Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                ],
            ),
            ),
        ],
        );
    }
    }