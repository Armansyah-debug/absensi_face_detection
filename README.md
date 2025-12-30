# absensi_face_detection

Aplikasi absensi wajah dengan integrasi Firebase, lokasi GPS, dan manajemen versi menggunakan FVM.

## Getting Started

Proyek ini menggunakan **FVM** (*Flutter Version Management*) untuk mengelola versi Flutter SDK. **Penting:** Semua anggota tim wajib menginstal FVM terlebih dahulu di komputer masing-masing.

### Prerequisites (Persyaratan Sistem Tim)

Untuk memastikan konsistensi dan menghindari error build, semua anggota tim wajib menggunakan versi berikut:

*   **Flutter SDK Version:** **3.22.2** • channel stable
    *   *Tools • Dart 3.4.3 • DevTools 2.34.3*
    *   *Versi ini akan otomatis diinstal FVM di langkah instalasi.*

*   **Java Development Kit (JDK):** **OpenJDK 17.0.17** atau yang lebih baru.
    *   Cara Cek: `java --version`
    *   *Penting: Android Gradle membutuhkan JDK 17 untuk proses build.*

*   **Firebase CLI:** Diperlukan untuk `flutterfire configure`.

### Installation (Langkah Instalasi untuk Tim)

Ikuti langkah-langkah ini secara berurutan di terminal masing-masing:

1.  **Install FVM (Hanya Sekali di Komputer Masing-masing):**

    *   *Di Windows (Gunakan PowerShell atau CMD):*
        ```bash
        dart pub global activate fvm
        # Pastikan folder Pub Cache ada di PATH Environment Variables Anda
        ```
    *   *Di macOS/Linux:*
        ```bash
        dart pub global activate fvm
        ```

2.  **Clone** repositori ini ke komputer lokal Anda:
    ```bash
    git clone github.com
    cd absensi_face_detection
    ```

3.  **Siapkan Flutter & Dependencies (Semua dalam satu alur):**
    ```bash
    fvm install && fvm use && fvm flutter pub get
    ```
    *Perintah ini menginstal Flutter versi 3.22.2, mengaturnya, dan mengunduh package.*

4.  **Instal & Konfigurasi Firebase CLI (Urutan Benar):**

    *   **Langkah A (Instal *Tools* CLI):** Jalankan ini **sekali** di laptop masing-masing:
        ```bash
        dart pub global activate flutterfire_cli
        ```

    *   **Langkah B (Sinkronisasi Proyek):** Pastikan Anda sudah *login* ke Firebase di browser (`firebase login`), lalu jalankan:
        ```bash
        fvm flutterfire configure
        ```

5.  **Jalankan Aplikasi:**
    ```bash
    fvm flutter run
    ```

## Resources

Beberapa sumber daya standar untuk memulai pengembangan Flutter:

*   [Lab: Write your first Flutter app](docs.flutter.dev)
*   [Cookbook: Useful Flutter samples](docs.flutter.dev)

## References

Proyek ini menggunakan referensi dari repositori GitHub berikut:

*   [github.com](github.com)

---
Copyright (c) 2025 Kelompok 3. Hak Cipta Dilindungi Undang-Undang.
