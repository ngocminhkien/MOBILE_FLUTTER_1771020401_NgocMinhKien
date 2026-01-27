class Tournament {
  final String id;
  final String name;
  final String status; 
  final String format; 
  final double prizePool;
  static List<Tournament> get mockData => [];

  Tournament({
    required this.id,
    required this.name,
    required this.status,
    required this.format,
    required this.prizePool,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'].toString(),
      name: json['name'],
      status: json['status'],
      format: json['format'],
      prizePool: (json['prizePool'] as num).toDouble(),
    );
  }
}