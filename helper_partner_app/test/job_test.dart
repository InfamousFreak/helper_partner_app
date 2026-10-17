    import 'package:flutter_test/flutter_test.dart';
    import 'package:helper_partner_app/data/job.dart';

    void main() {
    group('Job Model Tests', () {
        test('Job.fromJson correctly parses rich JSON payload', () {
        final json = {
            "id": "1",
            "job_title": "Senior Full-Stack Engineer",
            "location": "Remote",
            "company_name": "TechCorp",
            "skills": ["React", "Node.js"],
            "job_type": "Full-time",
            "salary": "15L - 25L",
            "experience": "5+ years",
            "description": "Test description",
            "posted_date": "2024-07-20",
            "is_hot": true,
            "status": "ASSIGNED"
        };

        final job = Job.fromJson(json);

        expect(job.id, '1');
        expect(job.jobTitle, 'Senior Full-Stack Engineer');
        expect(job.skills.length, 2);
        expect(job.isHot, true);
        });

        test('Job.fromJson handles missing optional fields gracefully', () {
        final json = {"id": "2"};

        final job = Job.fromJson(json);

        expect(job.id, '2');
        expect(job.jobTitle, 'Unknown Role');
        expect(job.status, 'ASSIGNED');
        expect(job.skills, isEmpty);
        });
    });
    }