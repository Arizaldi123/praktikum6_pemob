import 'package:flutter/material.dart'; // Mengimport package untuk pengembangan UI Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor library flutter_bloc untuk menggunakan Cubit.
import 'package:http/http.dart'
    as http; // Mengimpor library http dari package http untuk melakukan HTTP requests.
import 'dart:convert'; // Mengimpor library dart:convert untuk mengkonversi data.
import 'package:url_launcher/url_launcher.dart'; // Mengimpor library url_launcher untuk membuka URL.

void main() {
  runApp(const MyApp()); // Memulai aplikasi Flutter dengan widget MyApp.
}

class University {
  final String name; // Nama universitas.
  final List<String> webPages; // Daftar URL halaman web universitas.

  University({required this.name, required this.webPages});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Mengambil nama universitas dari JSON.
      webPages: List<String>.from(json[
          'web_pages']), // Mengambil daftar URL halaman web universitas dari JSON.
    );
  }
}

class UniversityCubit extends Cubit<List<University>> {
  String selectedCountry =
      'Indonesia'; // Default Negara yang dipilih untuk pencarian universitas.

  UniversityCubit()
      : super([]); // Inisialisasi state awal Cubit dengan list kosong.

  void changeCountry(String country) {
    selectedCountry = country; // Mengganti negara yang dipilih.
    fetchUniversities(); // Memanggil fungsi untuk memuat universitas berdasarkan negara baru.
  }

  void fetchUniversities() async {
    String apiUrl =
        'http://universities.hipolabs.com/search?country=$selectedCountry'; // URL API untuk mencari universitas berdasarkan negara.
    final response =
        await http.get(Uri.parse(apiUrl)); // Melakukan request HTTP GET.
    if (response.statusCode == 200) {
      List<dynamic> data =
          jsonDecode(response.body); // Mendekode response JSON.
      List<University> universities = data
          .map((json) => University.fromJson(json))
          .toList(); // Konversi data JSON menjadi list objek University.
      emit(universities); // Mengeluarkan state terbaru dengan list universitas.
    } else {
      throw Exception(
          'Failed to load universities'); // Melempar exception jika gagal memuat data universitas.
    }
  }
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  @override
  void initState() {
    super.initState();
    context
        .read<UniversityCubit>()
        .fetchUniversities(); // Memuat universitas saat initState dipanggil.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List Universitas ${context.watch<UniversityCubit>().selectedCountry}', // Judul AppBar dengan negara terpilih.
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // Warna latar AppBar.
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: context
                .watch<UniversityCubit>()
                .selectedCountry, // Nilai dropdown berasal dari negara terpilih dalam UniversityCubit.
            onChanged: (String? newValue) {
              if (newValue != null) {
                context.read<UniversityCubit>().changeCountry(
                    newValue); // Memperbarui negara terpilih saat dropdown diganti dan memuat universitas.
              }
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
                    Text(value), // Menampilkan nama negara pada item dropdown.
              );
            }).toList(),
          ),
          Expanded(
            child: BlocBuilder<UniversityCubit, List<University>>(
              builder: (context, universities) {
                return ListView.builder(
                  itemCount: universities
                      .length, // Jumlah universitas yang akan ditampilkan.
                  itemBuilder: (context, index) {
                    var university = universities[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(5),
                      child: ListTile(
                        title: Text(
                            university.name), // Menampilkan nama universitas.
                        subtitle: Text(
                          university.webPages
                              .first, // Menampilkan URL pertama dari list webPages.
                          style: TextStyle(color: Colors.blue), // Membuat teks URL menjadi berwarna biru
                        ),
                        onTap: () => launch(university.webPages
                            .first), // Membuka URL universitas di browser saat di-tap.
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final universityCubit = UniversityCubit();
    universityCubit
        .fetchUniversities(); // Memuat universitas saat UniversityCubit dibuat.

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UniversityCubit>(
            create: (BuildContext context) =>
                universityCubit, // Membuat instance dari UniversityCubit.
          ),
        ],
        child:
            UniversityList(), // UniversityList menjadi child dari MultiBlocProvider.
      ),
    );
  }
}
