import 'package:flutter/material.dart'; // Mengimpor package untuk pengembangan UI Flutter.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor library flutter_bloc untuk menggunakan Bloc.
import 'package:http/http.dart'
    as http; // Mengimpor library http dari package http untuk melakukan HTTP requests.
import 'dart:convert'; // Mengimpor library dart:convert untuk mengkonversi data.
import 'package:url_launcher/url_launcher.dart'; // Mengimpor library url_launcher untuk membuka URL.

void main() {
  runApp(MyApp()); // Menjalankan aplikasi dengan widget MyApp.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University App', // Judul aplikasi.
      home: BlocProvider(
        create: (context) =>
            UniversityBloc(), // Membuat instance dari UniversityBloc dan menyediakannya kepada widget-tree.
        child:
            UniversitiesPage(), // Menampilkan widget UniversitiesPage sebagai halaman utama.
      ),
    );
  }
}

class UniversityBloc extends Bloc<String, List<dynamic>> {
  UniversityBloc() : super([]) {
    on<String>((event, emit) async {
      var universities = await fetchUniversities(
          event); // Memanggil fungsi fetchUniversities saat event diterima.
      emit(universities); // Mengirimkan daftar universitas ke state.
    });

    // Initialize data with universities from Indonesia
    add('Indonesia'); // Memulai dengan memuat universitas dari Indonesia.
  }

  Future<List<dynamic>> fetchUniversities(String country) async {
    var url = Uri.parse(
        'http://universities.hipolabs.com/search?country=$country'); // URL API untuk mengambil universitas berdasarkan negara.
    try {
      final response = await http.get(url); // Melakukan HTTP GET request.
      if (response.statusCode == 200) {
        return json
            .decode(response.body); // Mengembalikan data JSON dari respons.
      } else {
        throw Exception(
            'Failed to load universities'); // Melempar exception jika gagal memuat data universitas.
      }
    } catch (e) {
      print(
          'Error fetching universities: $e'); // Menampilkan pesan error jika gagal memuat data.
      return []; // Mengembalikan list kosong jika terjadi error.
    }
  }
}

class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List Universitas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          CountryDropdown(), // Menampilkan dropdown untuk memilih negara.
          Expanded(
            child: BlocBuilder<UniversityBloc, List<dynamic>>(
              builder: (context, universities) {
                if (universities.isEmpty) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Menampilkan indikator loading jika daftar universitas kosong.
                } else {
                  return ListView.builder(
                    itemCount: universities.length,
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
                            university['name'], // Menampilkan nama universitas.
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            university['web_pages'][
                                0], // Menampilkan halaman web pertama universitas.
                            style: TextStyle(
                                color: Colors
                                    .blue), // Membuat teks URL berwarna biru
                          ),
                          onTap: () => _launchURL(university['web_pages'][
                              0]), // Mengarahkan ke halaman web universitas saat tile diklik.
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
          Uri.parse(url)); // Membuka URL saat fungsi _launchURL dipanggil.
    } else {
      print(
          'Could not launch $url'); // Menampilkan pesan error jika gagal membuka URL.
    }
  }
}

class CountryDropdown extends StatefulWidget {
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String? _currentSelectedValue = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    final universityBloc = BlocProvider.of<UniversityBloc>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        value: _currentSelectedValue,
        isExpanded: true,
        onChanged: (String? newValue) {
          setState(() {
            _currentSelectedValue = newValue; // Mengubah nilai negara terpilih.
          });
          universityBloc.add(
              newValue!); // Memanggil event di UniversityBloc saat nilai dropdown berubah.
        },
        items: [
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
            child: Text(value), // Menampilkan nama negara pada dropdown.
          );
        }).toList(),
      ),
    );
  }
}
