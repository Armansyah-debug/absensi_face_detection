# absensi_face_detection

Aplikasi absensi wajah dengan integrasi Firebase, lokasi GPS, dan manajemen versi menggunakan FVM.

## Getting Started

Proyek ini menggunakan **FVM** (*Flutter Version Management*) untuk mengelola versi Flutter SDK. **Penting:** Semua anggota tim wajib menginstal FVM terlebih dahulu di komputer masing-masing.

### Prerequisites (Persyaratan Sistem Tim)

Untuk memastikan konsistensi dan menghindari error build, semua anggota tim wajib menggunakan versi berikut:

*   **Flutter SDK Version:** **3.22.2** • channel stable
    *   *Tools • Dart 3.4.3 • DevTools 2.34.3*
    *   Cara Cek: `fvm flutter --version`
    *   Cara Install (jika belum ada): `fvm install 3.22.2`
    *   Cara Pakai di Proyek: `fvm use 3.22.2`

*   **Java Development Kit (JDK):** **OpenJDK 17.0.17** atau yang lebih baru.
    *   Cara Cek: `java --version`
    *   *Penting: Android Gradle membutuhkan JDK 17 untuk proses build.*

*   **Firebase CLI:** Diperlukan untuk `flutterfire configure`.
    *   Cara Install: `dart pub global activate flutterfire_cli`

### Installation (Langkah Instalasi untuk Tim)

1.  **Clone** repositori ini ke komputer lokal Anda:
    ```bash
    git clone github.com
    cd NAMA_REPO_ANDA
    ```
2.  **Gunakan FVM** untuk mengaktifkan versi Flutter yang benar:
    ```bash
    fvm install 
    fvm use
    ```
3.  **Install Dependencies** (package Flutter/Dart):
    ```bash
    fvm flutter pub get
    ```
4.  **Konfigurasi Firebase:** Pastikan sudah login via `firebase login` di terminal, lalu jalankan:
    ```bash
    fvm flutterfire configure
    ```
5.  **Jalankan Aplikasi:**
    ```bash
    fvm flutter run
    ```

## Resources

Beberapa sumber daya standar untuk memulai pengembangan Flutter:

- [Lab: Write your first Flutter app](docs.flutter.dev)
- [Cookbook: Useful Flutter samples](docs.flutter.dev)

## References

Proyek ini menggunakan referensi dari repositori GitHub berikut untuk beberapa inspirasi dan struktur kode:

*   [https://github.com/AzharRivaldi/absensi-face-detection-flutter.git](https://github.com/AzharRivaldi/absensi-face-detection-flutter.git)

---
Copyright (c) 2025 Kelompok 3. Hak Cipta Dilindungi Undang-Undang.
