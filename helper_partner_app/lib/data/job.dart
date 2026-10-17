    class Job {
    final String id;
    final String jobTitle;
    final String location;
    final String companyName;
    final List<String> skills;
    final String jobType;
    final String salary;
    final String experience;
    final String description;
    final String postedDate;
    final bool isHot;
    final String status;

    Job({
        required this.id,
        required this.jobTitle,
        required this.location,
        required this.companyName,
        required this.skills,
        required this.jobType,
        required this.salary,
        required this.experience,
        required this.description,
        required this.postedDate,
        required this.isHot,
        required this.status,
    });

    factory Job.fromJson(Map<String, dynamic> json) {
        return Job(
        id: json['id']?.toString() ?? '',
        jobTitle: json['job_title'] ?? 'Unknown Role',
        location: json['location'] ?? 'Unknown Location',
        companyName: json['company_name'] ?? '',
        skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        jobType: json['job_type'] ?? '',
        salary: json['salary'] ?? '',
        experience: json['experience'] ?? '',
        description: json['description'] ?? '',
        postedDate: json['posted_date'] ?? '',
        isHot: json['is_hot'] ?? false,
        status: json['status'] ?? 'ASSIGNED',
        );
    }
    }