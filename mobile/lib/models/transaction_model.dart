class WalletTransaction {
  final String id;
  final double amount;
  final String type;   
  final String status; 
  final String description;
  final DateTime createdDate;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.createdDate,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      status: json['status'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}