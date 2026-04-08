class OpenRouterCredits {
  final double totalCredits;

  final double totalUsage;

  OpenRouterCredits({required this.totalCredits, required this.totalUsage});

  double get remainingCredits => totalCredits - totalUsage;

  factory OpenRouterCredits.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;

    return OpenRouterCredits(
      totalCredits: (data["total_credits"] as num).toDouble(),
      totalUsage: (data["total_usage"] as num).toDouble(),
    );
  }

  @override
  String toString() =>
      "OpenRouterCredits(total: $totalCredits, usage: $totalUsage, balance: $remainingCredits)";
}
