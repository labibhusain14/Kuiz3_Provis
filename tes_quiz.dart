import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final JenisPinjamanCubit jenisPinjamanCubit = JenisPinjamanCubit();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JenisPinjamanCubit>.value(
      value: jenisPinjamanCubit,
      child: MaterialApp(
        home: const HalamanUtama(),
        routes: {
          DetilJenisPinjamanPage.routeName: (context) =>
              const DetilJenisPinjamanPage(),
        },
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '2101989, Mohammad Labib Husain; 2107922, Muhammad Rizki; Saya berjanji tidak akan berbuat curang data atau membuat orang lain berbuat curang',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              child: BlocBuilder<JenisPinjamanCubit, List<JenisPinjaman>>(
                builder: (context, state) {
                  return DropdownButton<String>(
                    value: context.watch<JenisPinjamanCubit>().selectedJenis,
                    hint: const Text('Pilih jenis pinjaman'),
                    items: state.map((jenisPinjaman) {
                      return DropdownMenuItem<String>(
                        value: jenisPinjaman.id,
                        child: Text(jenisPinjaman.nama),
                      );
                    }).toList(),
                    onChanged: (value) {
                      context
                          .read<JenisPinjamanCubit>()
                          .selectJenisPinjaman(value!);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<JenisPinjamanCubit, List<JenisPinjaman>>(
              builder: (context, state) {
                if (state.isEmpty) {
                  return const SizedBox(); // Placeholder widget when there's no data
                } else {
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.length,
                      itemBuilder: (context, index) {
                        final jenisPinjaman = state[index];
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
                                      jenisPinjaman.nama,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'id: ${jenisPinjaman.id}',
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
                                  context
                                      .read<JenisPinjamanCubit>()
                                      .fetchDetailJenisPinjaman(
                                          context, jenisPinjaman.id);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
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

class JenisPinjamanCubit extends Cubit<List<JenisPinjaman>> {
  String? selectedJenis;

  JenisPinjamanCubit() : super([]);

  void selectJenisPinjaman(String jenisId) {
    selectedJenis = jenisId;
    fetchData();
  }

  Future<void> fetchData() async {
    if (selectedJenis == null) {
      // Menampilkan pesan jika selectedJenis belum dipilih
      print('Pilih jenis pinjaman terlebih dahulu');
      emit([]); // Mengupdate state dengan list kosong
      return;
    }
    String url = "http://178.128.17.76:8000/jenis_pinjaman/$selectedJenis";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<JenisPinjaman> jenisPinjamanList =
          List<JenisPinjaman>.from(jsonData['data'].map(
        (json) => JenisPinjaman.fromJson(json),
      ));
      emit(jenisPinjamanList); // Mengupdate state dengan data yang di-fetch
    } else {
      throw Exception('Failed to load jenis pinjaman');
    }
  }

  Future<void> fetchDetailJenisPinjaman(BuildContext context, String id) async {
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
      isSyariah: json['is_syariah'],
    );
  }
}

class DetilJenisPinjamanPage extends StatelessWidget {
  static const routeName = '/detil_jenis_pinjaman';

  const DetilJenisPinjamanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detilJenisPinjaman =
        ModalRoute.of(context)!.settings.arguments as DetilJenisPinjaman;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detil Jenis Pinjaman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${detilJenisPinjaman.id}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Nama: ${detilJenisPinjaman.nama}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Bunga: ${detilJenisPinjaman.bunga}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Syariah: ${detilJenisPinjaman.isSyariah ? 'Ya' : 'Tidak'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
