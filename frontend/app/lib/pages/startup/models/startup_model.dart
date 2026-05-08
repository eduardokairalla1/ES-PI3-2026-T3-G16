/// --- Startup models ---
///
/// Eduardo Kairalla - 24024241

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
      name:      map['name']       as String? ?? '',
      role:      map['role']       as String? ?? '',
      equityPct: (map['equity_pct'] as num?)?.toDouble() ?? 0,
      bio:       map['bio']        as String?,
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
  final String? answer;
  final DateTime? answeredAt;
  final bool isPrivate;
  final DateTime createdAt;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.authorName,
    this.answer,
    this.answeredAt,
    required this.isPrivate,
    required this.createdAt,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id:         map['id']         as String? ?? '',
      text:       map['text']       as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      answer:     map['answer']     as String?,
      answeredAt: _parseTimestamp(map['answeredAt']),
      isPrivate:  map['isPrivate']  as bool? ?? false,
      createdAt:  _parseTimestamp(map['createdAt']) ?? DateTime.now(),
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
  final List<PartnerModel> partners;
  final List<AdvisorModel> advisors;
  final String? videoUrl;

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
    required this.partners,
    required this.advisors,
    this.videoUrl,
  });

  /// I return the translated stage label for display.
  String get stageLabel => switch (stage) {
    'new'       => 'Nova',
    'operating' => 'Em operação',
    'expanding' => 'Em expansão',
    _           => stage,
  };

  factory StartupModel.fromMap(Map<String, dynamic> map) {
    final rawPartners = (map['partners'] as List<dynamic>?) ?? [];
    final rawAdvisors = (map['advisors'] as List<dynamic>?) ?? [];

    return StartupModel(
      id:               map['id']               as String? ?? '',
      name:             map['name']             as String? ?? '',
      tagline:          map['tagline']          as String? ?? '',
      description:      map['description']      as String? ?? '',
      executiveSummary: map['executiveSummary'] as String? ?? '',
      stage:            map['stage']            as String? ?? 'new',
      logoUrl:          map['logoUrl']          as String? ?? '',
      tokenPrice:       (map['tokenPrice']   as num?)?.toDouble() ?? 0,
      capitalRaised:    (map['capitalRaised'] as num?)?.toDouble() ?? 0,
      totalTokens:      (map['totalTokens']  as num?)?.toInt()    ?? 0,
      partners: rawPartners
          .map((p) => PartnerModel.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList(),
      advisors: rawAdvisors
          .map((a) => AdvisorModel.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList(),
      videoUrl: map['videoUrl'] as String?,
    );
  }

  /// I return mock data for development without Firebase.
  factory StartupModel.mock() {
    return const StartupModel(
      id:   'mock-theracare',
      name: 'TheraCare',
      tagline:     'Saúde mental acessível para todos',
      description: 'Plataforma de telemedicina que conecta pacientes a psicólogos credenciados.',
      executiveSummary:
          'O Brasil possui apenas 3,2 psicólogos por 10.000 habitantes, muito abaixo da média '
          'recomendada pela OMS. A TheraCare resolve esse gargalo oferecendo teleconsultas de '
          'saúde mental com psicólogos credenciados pelo CFP, a partir de R\$ 80 por sessão. '
          'Nosso modelo SaaS cobra uma comissão de 20% por sessão realizada, sem mensalidade '
          'para os profissionais. Em 3 meses de operação no modo beta fechado, validamos 47 '
          'sessões com NPS de 92. Buscamos R\$ 200.000 em capital semente para escalar a '
          'aquisição de usuários e contratar 2 desenvolvedores.',
      stage:         'new',
      logoUrl:       'https://placehold.co/200x200/4F46E5/FFFFFF?text=TC',
      tokenPrice:    0.10,
      capitalRaised: 18000,
      totalTokens:   1000000,
      videoUrl:      null,
      partners: [
        PartnerModel(
          name:      'Ana Paula Ferreira',
          role:      'CEO & Co-fundadora',
          equityPct: 60,
          bio:       'Psicóloga formada pela PUC-Campinas, especialista em TCC.',
        ),
        PartnerModel(
          name:      'Lucas Mendes',
          role:      'CTO & Co-fundador',
          equityPct: 40,
          bio:       'Engenheiro de Software pela Unicamp, 4 anos de experiência mobile.',
        ),
      ],
      advisors: [
        AdvisorModel(name: 'Prof. Dr. Ricardo Alves', role: 'Mentor de Negócios'),
      ],
    );
  }
}
