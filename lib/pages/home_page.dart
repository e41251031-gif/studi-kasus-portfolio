import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../db/database_helper.dart';
import '../models/portfolio.dart';
import 'portfolio_card.dart';
import 'profile_photo.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _banner = PageController(viewportFraction: 0.92);
  int _bannerIndex = 0;
  Timer? _timer;

  Profile? _profile;
  List<Portfolio> _latest = [];

  static const _banners = [
    (Icons.rocket_launch, 'Selamat Datang', 'Kumpulan karya dan proyek mahasiswa POLIJE'),
    (Icons.storage, 'Data Tersimpan', 'Portofolio disimpan di database SQLite pada perangkat'),
    (Icons.school, 'Kenali POLIJE', 'Politeknik Negeri Jember: pendidikan vokasi berbasis praktik'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
    AppState.dataVersion.addListener(_load);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_banner.hasClients) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _banner.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _banner.dispose();
    AppState.dataVersion.removeListener(_load);
    super.dispose();
  }

  String? _error;

  Future<void> _load() async {
    try {
      final p = await DatabaseHelper.instance.getProfile();
      final list = await DatabaseHelper.instance.getPortfolios();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _latest = list.take(3).toList();
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Header gradient
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          decoration: const BoxDecoration(
            gradient: kHeaderGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Row(
            children: [
              const ProfilePhoto(radius: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halo,', style: TextStyle(color: Colors.white70)),
                    Text(
                      _profile?.name ?? '...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _profile == null
                          ? ''
                          : '${_profile!.studyProgram} · ${_profile!.department}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // PageView banner informasi
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _banner,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: kHeaderGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(b.$1, color: Colors.white, size: 40),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.$2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(b.$3, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.all(4),
              width: _bannerIndex == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _bannerIndex == i ? kPrimary : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        // Pintasan menu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _shortcut(Icons.collections_bookmark, 'Karya', 1),
              _shortcut(Icons.add_box, 'Tambah', 2),
              _shortcut(Icons.school, 'POLIJE', 3),
              _shortcut(Icons.person, 'Profil', 4),
              _shortcut(Icons.settings, 'Pengaturan', 5),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Karya Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Gagal memuat data: $_error',
                style: const TextStyle(color: Colors.redAccent)),
          )
        else if (_latest.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Belum ada karya. Tambahkan lewat menu Tambah.'),
          ),
        for (final p in _latest)
          PortfolioCard(item: p, onTap: () => showPortfolioDetail(context, p)),
      ],
    );
  }

  Widget _shortcut(IconData icon, String label, int target) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => widget.onNavigate(target),
    );
  }
}
