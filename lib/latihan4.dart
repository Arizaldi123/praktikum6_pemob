import 'package:flutter/material.dart'; // Mengimport package untuk pengembangan UI Flutter
import 'package:http/http.dart'
    as http; // Mengimport package HTTP client untuk melakukan permintaan jaringan
import 'dart:convert'; // Mengimport library untuk decoding JSON
import 'package:provider/provider.dart'; // Mengimport package Provider untuk manajemen state
import 'package:url_launcher/url_launcher.dart'; // Mengimport package URL launcher untuk membuka tautan web

void main() {
  runApp(
    ChangeNotifierProvider(
      // Membungkus aplikasi dengan ChangeNotifierProvider untuk menyediakan UniversityProvider ke dalam tree widget
      create: (context) =>
          UniversityProvider(), // Membuat instance dari UniversityProvider
      child: MyApp(), // Menggunakan widget MyApp sebagai root dari tree widget
    ),
  );
}

// Kelas University mewakili entitas universitas
class University {
  final String name; // Nama universitas
  final List<String> webPages; // Daftar halaman web universitas

  University(
      {required this.name,
      required this.webPages}); // Konstruktor untuk University

  // Factory constructor untuk mengubah data JSON menjadi objek University
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      webPages: List<String>.from(json['web_pages']),
    );
  }
}

// UniversityProvider class untuk mengelola data universitas dan state
class UniversityProvider extends ChangeNotifier {
  String selectedCountry = 'Indonesia'; // Negara terpilih secara default
  List<University> universities = []; // List universitas

  UniversityProvider() {
    fetchUniversities(); // Memuat data universitas saat provider diinisialisasi
  }

  // Metode untuk mengubah negara terpilih dan memuat data universitas sesuai dengan negara tersebut
  void changeCountry(String country) {
    selectedCountry = country;
    fetchUniversities();
  }

  // Metode untuk memuat data universitas dari API
  void fetchUniversities() async {
    String apiUrl =
        'http://universities.hipolabs.com/search?country=$selectedCountry';
    final response =
        await http.get(Uri.parse(apiUrl)); // Mengirim permintaan GET ke API
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body); // Mendecode respons JSON
      universities = data
          .map((json) => University.fromJson(json))
          .toList(); // Mengonversi data JSON menjadi objek University
      notifyListeners(); // Memberitahu para listener bahwa state telah berubah
    } else {
      throw Exception(
          'Failed to load universities'); // Melemparkan exception jika gagal memuat data
    }
  }
}

// Widget UniversityList untuk menampilkan daftar universitas
class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'List Universitas ${Provider.of<UniversityProvider>(context).selectedCountry}',
            style: TextStyle(
                color: Colors
                    .white)), // Menampilkan negara terpilih di judul app bar
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: Provider.of<UniversityProvider>(context).selectedCountry,
            onChanged: (String? newValue) {
              if (newValue != null)
                Provider.of<UniversityProvider>(context, listen: false)
                    .changeCountry(
                        newValue); // Mengubah negara terpilih saat nilai dropdown berubah
            },
            items: <String>[
              'Indonesia',
              'Malaysia',
              'Singapore',
              'Brunei Darussalam',
              'Philippines',
              'Thailand',
              'Cambodia',
              'Vietnam',
              'Myanmar'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child:
                    Text(value), // Menampilkan item dropdown dengan nama negara
              );
            }).toList(),
          ),
          Expanded(
            child: Consumer<UniversityProvider>(
              builder: (context, provider, child) => ListView.builder(
                itemCount: provider.universities.length,
                itemBuilder: (context, index) {
                  var university = provider.universities[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(5),
                    child: ListTile(
                      title:
                          Text(university.name), // Menampilkan nama universitas
                      subtitle: Text(
                        university.webPages.first,
                        style: TextStyle(
                            color: Colors
                                .blue), // Menampilkan URL universitas dengan warna biru
                      ),
                      onTap: () => launch(university.webPages
                          .first), // Membuka halaman web universitas ketika diklik
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MyApp widget sebagai root dari aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University App',
      theme: ThemeData(primarySwatch: Colors.blue), // Mengatur tema aplikasi
      home:
          UniversityList(), // Mengatur widget UniversityList sebagai halaman utama
    );
  }
}
