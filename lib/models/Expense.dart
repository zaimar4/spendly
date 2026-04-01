class Expense {
  final String id;
  final String nama;
  final double harga;
  final DateTime tanggal;
  final String kategori;
  Expense({
    required this.id,
    required this.nama,
    required this.harga,
    required this.tanggal,
    required this.kategori,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      nama: json['nama_expense'] ?? '', // anti null
      harga: (json['harga'] ?? 0).toDouble(),
      tanggal: DateTime.parse(json['created_at']),
      kategori: json['kategori'] ?? '',
    );
  }
  Map<String, dynamic> toJson(String userId) {
    return {
      "user_id": userId,
      "nama_expense": nama,
      "harga": harga,
      "kategori": kategori,
    };
  }
}
