import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HalamanUtama(),
      routes: {
        DetilJenisPinjamanPage.routeName: (context) => DetilJenisPinjamanPage(),
      },
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // String selectedJenis = '1';
  String? selectedJenis; // Change the type to String?
  List<JenisPinjaman> jenisPinjamanList = [];

  Future<List<JenisPinjaman>> fetchData() async {
    if (selectedJenis == null) {
      // Menampilkan pesan jika selectedJenis belum dipilih
      print('Pilih jenis pinjaman terlebih dahulu');
      return []; // Mengembalikan list kosong
    }

    String url = "http://178.128.17.76:8000/jenis_pinjaman/$selectedJenis";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      jenisPinjamanList = List<JenisPinjaman>.from(jsonData['data'].map(
        (json) => JenisPinjaman.fromJson(json),
      ));
      return jenisPinjamanList;
    } else {
      throw Exception('Failed to load jenis pinjaman');
    }
  }

  Future<void> fetchDetilJenisPinjaman(String id) async {
    String url = "http://178.128.17.76:8000/detil_jenis_pinjaman/$id";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var detilJenisPinjaman = DetilJenisPinjaman.fromJson(jsonData);
      Navigator.pushNamed(
        context,
        DetilJenisPinjamanPage.routeName,
        arguments: detilJenisPinjaman,
      );
    } else {
      throw Exception('Failed to load detil jenis pinjaman');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App P2P'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Center align the dropdown
          children: [
            const SizedBox(height: 16),
            const Text(
              '2101989, Mohammad Labib Husain; 2107922, Muhammad Rizki; Saya berjanji tidak akan berbuat curang data atau membuat orang lain berbuat curang',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              // Wrap the DropdownButton with Center widget
              child: DropdownButton<String>(
                value: selectedJenis,
                hint: const Text('Pilih jenis pinjaman'), // Menampilkan hint
                items: [
                  DropdownMenuItem<String>(
                    value: '1',
                    child: const Text('Pilihan 1'),
                  ),
                  DropdownMenuItem<String>(
                    value: '2',
                    child: const Text('Pilihan 2'),
                  ),
                  DropdownMenuItem<String>(
                    value: '3',
                    child: const Text('Pilihan 3'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedJenis = value!;
                  });
                  fetchData();
                },
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<JenisPinjaman>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                leading: Image.network(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                                  width: 50,
                                  height: 50,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![index].nama,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'id: ${snapshot.data![index].id}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      // Handle edit action
                                    } else if (value == 'delete') {
                                      // Handle delete action
                                    }
                                  },
                                ),
                                onTap: () {
                                  fetchDetilJenisPinjaman(
                                      snapshot.data![index].id);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox(); // Placeholder widget when there's no data
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class JenisPinjaman {
  String id;
  String nama;

  JenisPinjaman({required this.id, required this.nama});

  factory JenisPinjaman.fromJson(Map<String, dynamic> json) {
    return JenisPinjaman(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class DetilJenisPinjaman {
  String id;
  String nama;
  String bunga;
  bool isSyariah;

  DetilJenisPinjaman({
    required this.id,
    required this.nama,
    required this.bunga,
    required this.isSyariah,
  });

  factory DetilJenisPinjaman.fromJson(Map<String, dynamic> json) {
    return DetilJenisPinjaman(
      id: json['id'],
      nama: json['nama'],
      bunga: json['bunga'],
      isSyariah: json['is_syariah'] == 'YA', // Convert string to boolean
    );
  }
}

class DetilJenisPinjamanPage extends StatelessWidget {
  static const routeName = '/detil_jenis_pinjaman';

  @override
  Widget build(BuildContext context) {
    final detilJenisPinjaman =
        ModalRoute.of(context)!.settings.arguments as DetilJenisPinjaman;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detil'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('id: ${detilJenisPinjaman.id}'),
          Text('Nama: ${detilJenisPinjaman.nama}'),
          Text('Bunga: ${detilJenisPinjaman.bunga}'),
          Text('Syariah: ${detilJenisPinjaman.isSyariah ? 'YA' : 'TIDAK'}'),
        ],
      ),
    );
  }
}
