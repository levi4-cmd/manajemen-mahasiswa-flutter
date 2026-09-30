import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Model data mahasiswa
class Mahasiswa {
  String nim;
  String nama;
  String prodi;
  String kelas;

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.kelas,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HalamanDaftar(),
    );
  }
}

// ===================== HALAMAN DAFTAR =====================
class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  final List<Mahasiswa> _data = [
    Mahasiswa(nim: '25781037', nama: 'Levi muhammad wahyu', prodi: 'Manajemen Informatika', kelas: 'MI-3B'),
    Mahasiswa(nim: '231002', nama: 'Budi Santoso', prodi: 'Informatika', kelas: 'TI-3A'),
    Mahasiswa(nim: '231003', nama: 'Citra Lestari', prodi: 'Sistem Informasi', kelas: 'SI-3B'),
    Mahasiswa(nim: '231004', nama: 'Dewi Anggraini', prodi: 'Teknik Komputer', kelas: 'TK-3A'),
    Mahasiswa(nim: '231005', nama: 'Eko Prasetyo', prodi: 'Sistem Informasi', kelas: 'SI-3A'),
    Mahasiswa(nim: '25781048', nama: 'Sally', prodi: 'Manajemen Informatika', kelas: 'MI.B'),
  ];

  // TAHAP 7: pencarian
  final TextEditingController _cariController = TextEditingController();
  String _kataKunci = '';

  // TANTANGAN 1: filter program studi
  final List<String> _opsiProdi = [
    'Semua',
    'Informatika',
    'Manajemen Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];
  String _filterProdi = 'Semua';

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // Daftar yang ditampilkan = data yang cocok dengan pencarian DAN filter.
  // List _data sendiri tidak diubah.
  List<Mahasiswa> get _hasil {
    final q = _kataKunci.toLowerCase();
    return _data.where((m) {
      final cocokCari =
          m.nama.toLowerCase().contains(q) || m.nim.toLowerCase().contains(q);
      final cocokProdi = _filterProdi == 'Semua' || m.prodi == _filterProdi;
      return cocokCari && cocokProdi;
    }).toList();
  }

  Future<void> _tambah() async {
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (_) => const FormMahasiswa()),
    );
    if (hasil != null) {
      setState(() {
        _data.add(hasil);
      });
    }
  }

  Future<void> _bukaDetail(Mahasiswa m) async {
    final hasil = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => HalamanDetail(mahasiswa: m)),
    );
    if (hasil == null) return;

    setState(() {
      final index = _data.indexOf(m);
      if (hasil['aksi'] == 'edit') {
        _data[index] = hasil['data'] as Mahasiswa;
      } else if (hasil['aksi'] == 'hapus') {
        _data.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _hasil;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Mahasiswa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
      body: Column(
        children: [
          // TANTANGAN 2: total mahasiswa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Mahasiswa: ${_data.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // TAHAP 7: kolom pencarian
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _cariController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama atau NIM...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _kataKunci = value;
                });
              },
            ),
          ),
          // TANTANGAN 1: dropdown filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              initialValue: _filterProdi,
              decoration: const InputDecoration(
                labelText: 'Filter Program Studi',
                border: OutlineInputBorder(),
              ),
              items: _opsiProdi
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _filterProdi = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            // TANTANGAN 3: empty state
            child: tampil.isEmpty
                ? Center(
                    child: Text(
                      _data.isEmpty
                          ? 'Belum ada data mahasiswa'
                          : 'Data tidak ditemukan',
                    ),
                  )
                : ListView.builder(
                    itemCount: tampil.length,
                    itemBuilder: (context, index) {
                      final m = tampil[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            width: 90,
                            child: Text(
                              m.nim,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(m.nama),
                          subtitle: Text('${m.prodi}\n${m.kelas}'),
                          isThreeLine: true,
                          onTap: () => _bukaDetail(m),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ===================== HALAMAN DETAIL + EDIT + HAPUS =====================
class HalamanDetail extends StatefulWidget {
  final Mahasiswa mahasiswa;
  const HalamanDetail({super.key, required this.mahasiswa});

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  Future<void> _edit() async {
    final baru = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswa(mahasiswa: widget.mahasiswa),
      ),
    );
    if (baru != null && mounted) {
      Navigator.pop(context, {'aksi': 'edit', 'data': baru});
    }
  }

  Future<void> _hapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin == true && mounted) {
      Navigator.pop(context, {'aksi': 'hapus'});
    }
  }

  Widget _baris(String label, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            isi,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mahasiswa;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baris('NIM', m.nim),
            _baris('Nama', m.nama),
            _baris('Program Studi', m.prodi),
            _baris('Kelas', m.kelas),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _hapus,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== FORM TAMBAH / EDIT =====================
class FormMahasiswa extends StatefulWidget {
  final Mahasiswa? mahasiswa; // null = mode tambah, ada isi = mode edit
  const FormMahasiswa({super.key, this.mahasiswa});

  @override
  State<FormMahasiswa> createState() => _FormMahasiswaState();
}

class _FormMahasiswaState extends State<FormMahasiswa> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nimC;
  late final TextEditingController _namaC;
  late final TextEditingController _prodiC;
  late final TextEditingController _kelasC;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    _nimC = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _namaC = TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _prodiC = TextEditingController(text: widget.mahasiswa?.prodi ?? '');
    _kelasC = TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _nimC.dispose();
    _namaC.dispose();
    _prodiC.dispose();
    _kelasC.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Mahasiswa(
          nim: _nimC.text.trim(),
          nama: _namaC.text.trim(),
          prodi: _prodiC.text.trim(),
          kelas: _kelasC.text.trim(),
        ),
      );
    }
  }

  Widget _field(TextEditingController c, String label, String pesan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return pesan;
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Mahasiswa' : 'Tambah Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_nimC, 'NIM', 'NIM wajib diisi'),
              _field(_namaC, 'Nama', 'Nama wajib diisi'),
              _field(_prodiC, 'Program Studi', 'Program Studi wajib diisi'),
              _field(_kelasC, 'Kelas', 'Kelas wajib diisi'),
              ElevatedButton(
                onPressed: _simpan,
                child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}