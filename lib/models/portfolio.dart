class Portfolio {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String technology;
  final String imageUrl;
  final String projectUrl;
  final int year;

  const Portfolio({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.technology,
    this.imageUrl = '',
    this.projectUrl = '',
    required this.year,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'technology': technology,
        'image_url': imageUrl,
        'project_url': projectUrl,
        'year': year,
      };

  factory Portfolio.fromMap(Map<String, Object?> m) => Portfolio(
        id: m['id'] as int?,
        title: m['title'] as String,
        description: m['description'] as String,
        category: m['category'] as String,
        technology: m['technology'] as String,
        imageUrl: (m['image_url'] as String?) ?? '',
        projectUrl: (m['project_url'] as String?) ?? '',
        year: m['year'] as int,
      );
}

class Profile {
  final String name;
  final String nim;
  final String studyProgram;
  final String department;
  final String email;
  final String bio;
  final String skills;

  const Profile({
    required this.name,
    required this.nim,
    required this.studyProgram,
    required this.department,
    required this.email,
    required this.bio,
    required this.skills,
  });

  Map<String, Object?> toMap() => {
        'id': 1,
        'name': name,
        'nim': nim,
        'study_program': studyProgram,
        'department': department,
        'email': email,
        'bio': bio,
        'skills': skills,
      };

  factory Profile.fromMap(Map<String, Object?> m) => Profile(
        name: m['name'] as String,
        nim: m['nim'] as String,
        studyProgram: m['study_program'] as String,
        department: m['department'] as String,
        email: m['email'] as String,
        bio: m['bio'] as String,
        skills: m['skills'] as String,
      );
}

const List<String> kCategories = [
  'Mobile App',
  'Web',
  'UI/UX Design',
  'Data',
  'IoT',
  'Lainnya',
];

const List<String> kTechnologies = [
  'Flutter',
  'Laravel',
  'React',
  'Figma',
  'Python',
  'Arduino',
  'Lainnya',
];
