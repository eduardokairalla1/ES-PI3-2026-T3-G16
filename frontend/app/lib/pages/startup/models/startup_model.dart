// --- Startup models ---
//
// Eduardo Kairalla - 24024241

// --- HELPERS ---

DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    final seconds = (value['_seconds'] as num?)?.toInt() ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  return null;
}

// --- MODELS ---

class PartnerModel {
  final String name;
  final String role;
  final double equityPct;
  final String? bio;
  final String? avatarUrl;

  const PartnerModel({
    required this.name,
    required this.role,
    required this.equityPct,
    this.bio,
    this.avatarUrl,
  });

  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      equityPct: (map['equity_pct'] as num?)?.toDouble() ?? 0,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class AdvisorModel {
  final String name;
  final String role;

  const AdvisorModel({required this.name, required this.role});

  factory AdvisorModel.fromMap(Map<String, dynamic> map) {
    return AdvisorModel(
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
    );
  }
}

class QuestionModel {
  final String id;
  final String text;
  final String authorName;
  final String? authorUid;
  final String? answer;
  final DateTime? answeredAt;
  final bool isPrivate;
  final DateTime createdAt;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.authorName,
    this.authorUid,
    this.answer,
    this.answeredAt,
    required this.isPrivate,
    required this.createdAt,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorUid: map['authorUid'] as String?,
      answer: map['answer'] as String?,
      answeredAt: _parseTimestamp(map['answeredAt']),
      isPrivate: map['isPrivate'] as bool? ?? false,
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
    );
  }
}

class StartupModel {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String executiveSummary;
  final String stage;
  final String logoUrl;
  final double tokenPrice;
  final double capitalRaised;
  final int totalTokens;
  final int availableTokens;
  final String tokenName;
  final List<PartnerModel> partners;
  final List<AdvisorModel> advisors;
  final String? videoUrl;
  final double? changePercent;

  const StartupModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.executiveSummary,
    required this.stage,
    required this.logoUrl,
    required this.tokenPrice,
    required this.capitalRaised,
    required this.totalTokens,
    required this.availableTokens,
    required this.tokenName,
    required this.partners,
    required this.advisors,
    this.videoUrl,
    this.changePercent,
  });

  /// Percentage of total tokens already sold (primary market).
  /// Derived: (total - available) / total × 100.
  double get soldPercent {
    if (totalTokens <= 0) return 0;
    final sold = totalTokens - availableTokens;
    if (sold <= 0) return 0;
    return (sold / totalTokens) * 100;
  }

  /// I return the translated stage label for display.
  String get stageLabel => switch (stage) {
    'new' => 'Nova',
    'operating' => 'Em operação',
    'expanding' => 'Em expansão',
    _ => stage,
  };

  factory StartupModel.fromMap(Map<String, dynamic> map) {
    final rawPartners = (map['partners'] as List<dynamic>?) ?? [];
    final rawAdvisors = (map['advisors'] as List<dynamic>?) ?? [];

    return StartupModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      tagline: map['tagline'] as String? ?? '',
      description: map['description'] as String? ?? '',
      executiveSummary: map['executiveSummary'] as String? ?? '',
      stage: map['stage'] as String? ?? 'new',
      logoUrl: map['logoUrl'] as String? ?? '',
      tokenPrice: (map['tokenPrice'] as num?)?.toDouble() ?? 0,
      capitalRaised: (map['capitalRaised'] as num?)?.toDouble() ?? 0,
      totalTokens: (map['totalTokens'] as num?)?.toInt() ?? 0,
      availableTokens: (map['availableTokens'] as num?)?.toInt() ?? 0,
      tokenName: (map['tokenName'] as String?) ?? '',
      partners: rawPartners
          .map((p) => PartnerModel.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList(),
      advisors: rawAdvisors
          .map((a) => AdvisorModel.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList(),
      videoUrl:      map['videoUrl']      as String?,
      changePercent: (map['changePercent'] as num?)?.toDouble(),
    );
  }
}
