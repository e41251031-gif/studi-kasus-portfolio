import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/portfolio.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'polije_portfolio_v2.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE portfolio(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        technology TEXT NOT NULL,
        image_url TEXT,
        project_url TEXT,
        year INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE profile(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        nim TEXT NOT NULL,
        study_program TEXT NOT NULL,
        department TEXT NOT NULL,
        email TEXT NOT NULL,
        bio TEXT NOT NULL,
        skills TEXT NOT NULL
      )
    ''');

    // Data awal: ganti lewat menu Profil Saya dan Portofolio di aplikasi.
    await db.insert(
      'profile',
      const Profile(
        name: 'Siti Maisyaroh',
        nim: 'E41251031',
        studyProgram: 'Program Studi Anda',
        department: 'Teknologi Informasi',
        email: 'e41251031@student.polije.ac.id',
        bio:
            'Mahasiswa Politeknik Negeri Jember yang tertarik pada pengembangan aplikasi mobile.',
        skills: 'Flutter, Dart, SQLite, UI Design',
      ).toMap(),
    );

    const seeds = [
      Portfolio(
        title: 'Aplikasi Catatan Harian',
        description: 'Aplikasi pencatat kegiatan harian dengan penyimpanan lokal.',
        category: 'Mobile App',
        technology: 'Flutter',
        year: 2025,
      ),
      Portfolio(
        title: 'Website Profil Kelas',
        description: 'Website informasi kelas berisi jadwal dan galeri kegiatan.',
        category: 'Web',
        technology: 'Laravel',
        year: 2025,
      ),
      Portfolio(
        title: 'Desain UI Aplikasi Kampus',
        description: 'Prototipe antarmuka aplikasi informasi kampus.',
        category: 'UI/UX Design',
        technology: 'Figma',
        year: 2025,
      ),
      Portfolio(
        title: 'Dashboard Data Nilai',
        description: 'Visualisasi sederhana data nilai praktikum mahasiswa.',
        category: 'Data',
        technology: 'Python',
        year: 2026,
      ),
      Portfolio(
        title: 'Monitor Suhu Ruangan',
        description: 'Prototipe sensor suhu dengan tampilan nilai secara langsung.',
        category: 'IoT',
        technology: 'Arduino',
        year: 2026,
      ),
    ];
    for (final p in seeds) {
      await db.insert('portfolio', p.toMap()..remove('id'));
    }
  }

  // ---------- CRUD Portofolio ----------

  Future<int> insertPortfolio(Portfolio p) async {
    final db = await database;
    return db.insert('portfolio', p.toMap()..remove('id'));
  }

  Future<List<Portfolio>> getPortfolios({String? category}) async {
    final db = await database;
    final rows = await db.query(
      'portfolio',
      where: (category == null || category == 'Semua') ? null : 'category = ?',
      whereArgs: (category == null || category == 'Semua') ? null : [category],
      orderBy: 'id DESC',
    );
    return rows.map(Portfolio.fromMap).toList();
  }

  Future<int> updatePortfolio(Portfolio p) async {
    final db = await database;
    return db.update(
      'portfolio',
      p.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<int> deletePortfolio(int id) async {
    final db = await database;
    return db.delete('portfolio', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Profil ----------

  Future<Profile> getProfile() async {
    final db = await database;
    final rows = await db.query('profile', where: 'id = 1');
    return Profile.fromMap(rows.first);
  }

  Future<void> saveProfile(Profile p) async {
    final db = await database;
    await db.update('profile', p.toMap()..remove('id'), where: 'id = 1');
  }
}
