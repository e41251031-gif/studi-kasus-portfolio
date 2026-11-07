import 'package:flutter/material.dart';

/// Foto profil bulat. Berkas foto: assets/profil.jpg
class ProfilePhoto extends StatelessWidget {
  final double radius;
  const ProfilePhoto({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/profil.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          // Kalau foto tidak ditemukan, tampil ikon orang.
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            color: Colors.blueGrey,
            child: Icon(Icons.person, size: radius, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
