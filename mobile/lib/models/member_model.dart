class Member {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final double walletBalance;
  final String tier; 
  final double rankLevel;

  Member({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.walletBalance,
    required this.tier,
    required this.rankLevel,
  });

  // Chuyển từ JSON nhận từ API .NET sang Object trong Flutter
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      fullName: json['fullName'] ?? "Người dùng",
      avatarUrl: json['avatarUrl'],
      walletBalance: (json['walletBalance'] as num).toDouble(),
      tier: json['tier'] ?? "Standard",
      rankLevel: (json['rankLevel'] as num).toDouble(),
    );
  }
}