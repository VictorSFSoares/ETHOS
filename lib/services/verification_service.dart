import '../models/data_models.dart';

/// Serviço de Verificação - Dados fornecidos pela equipe ETHOS
/// Este serviço gerencia verificações de conteúdo suspeito
/// Todas as verificações são realizadas pela nossa equipe especializada
class VerificationService {
  // Singleton
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  // Banco de verificações recentes (simulando dados da equipe)
  final List<VerificationItem> _verificationsDatabase = [
    VerificationItem(
      id: '1',
      content: 'Vídeo sobre tratamento milagroso para câncer',
      type: 'link',
      source: 'WhatsApp',
      verifiedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      status: VerificationStatus.fakeNews,
      confidence: 95,
      details: 'Conteúdo promove tratamentos não comprovados cientificamente. Nenhum estudo clínico valida as alegações.',
    ),
    VerificationItem(
      id: '2',
      content: 'Anúncio de concurso público federal',
      type: 'link',
      source: 'Facebook',
      verifiedAt: DateTime.now().subtract(const Duration(minutes: 34)),
      status: VerificationStatus.verified,
      confidence: 98,
      details: 'Informação confirmada no Diário Oficial da União. Edital publicado em 15/03/2026.',
    ),
    VerificationItem(
      id: '3',
      content: 'Notícia sobre mudança na legislação tributária',
      type: 'text',
      source: 'Instagram',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: VerificationStatus.suspicious,
      confidence: 70,
      details: 'Informação parcialmente correta. A mudança foi proposta, mas ainda não foi aprovada.',
    ),
    VerificationItem(
      id: '4',
      content: 'Promoção de banco com crédito facilitado',
      type: 'link',
      source: 'Email',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: VerificationStatus.fakeNews,
      confidence: 99,
      details: 'Golpe de phishing identificado. O banco confirmou que não enviou esta comunicação.',
    ),
    VerificationItem(
      id: '5',
      content: 'https://exemplo.com/noticias-governo-2026',
      type: 'link',
      source: 'Link Direto',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: VerificationStatus.verified,
      confidence: 94,
      details: 'Site oficial do governo. Informações verificadas e atualizadas.',
    ),
    VerificationItem(
      id: '6',
      content: 'Vacina contra COVID-19 causa alterações no DNA',
      type: 'text',
      source: 'WhatsApp',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: VerificationStatus.fakeNews,
      confidence: 100,
      details: 'Desinformação científica. Vacinas de mRNA não alteram o DNA humano, conforme comprovado por estudos.',
    ),
    VerificationItem(
      id: '7',
      content: 'Foto_manifestação.jpg',
      type: 'image',
      source: 'Telegram',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: VerificationStatus.suspicious,
      confidence: 65,
      details: 'Imagem é real, mas foi tirada em contexto diferente do alegado. Data e local não correspondem.',
    ),
    VerificationItem(
      id: '8',
      content: 'https://economia.uol.com.br/dolar-hoje',
      type: 'link',
      source: 'Link Direto',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: VerificationStatus.verified,
      confidence: 100,
      details: 'Site de notícias confiável. Informação de cotação atualizada em tempo real.',
    ),
    VerificationItem(
      id: '9',
      content: 'Áudio sobre suposta fraude em eleições',
      type: 'audio',
      source: 'WhatsApp',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 8)),
      status: VerificationStatus.fakeNews,
      confidence: 97,
      details: 'Áudio manipulado. Análise de voz indica edição e cortes. TSE desmentiu as alegações.',
    ),
    VerificationItem(
      id: '10',
      content: 'Nova lei do IPVA 2026 com desconto de 50%',
      type: 'text',
      source: 'Facebook',
      verifiedAt: DateTime.now().subtract(const Duration(hours: 12)),
      status: VerificationStatus.fakeNews,
      confidence: 100,
      details: 'Informação falsa. Nenhum estado brasileiro aprovou lei com esse teor.',
    ),
  ];

  // Lista de verificações do usuário
  final List<VerificationItem> _userVerifications = [];

  // Obter todas as verificações recentes
  Future<List<VerificationItem>> getRecentVerifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_verificationsDatabase)
      ..sort((a, b) => b.verifiedAt.compareTo(a.verifiedAt));
  }

  // Obter verificações do usuário
  Future<List<VerificationItem>> getUserVerifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allVerifications = [..._userVerifications, ..._verificationsDatabase];
    return allVerifications..sort((a, b) => b.verifiedAt.compareTo(a.verifiedAt));
  }

  // Obter verificações por status
  Future<List<VerificationItem>> getVerificationsByStatus(VerificationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = await getUserVerifications();
    return all.where((v) => v.status == status).toList();
  }

  // Realizar nova verificação
  Future<VerificationItem> verifyContent(String content, String type) async {
    // Simula processamento
    await Future.delayed(const Duration(seconds: 2));

    // Lógica de verificação simulada (na prática, seria a API da equipe)
    final VerificationStatus status;
    final int confidence;
    final String details;
    final String source;

    // Detecta fonte baseado no conteúdo
    if (content.contains('whatsapp') || content.contains('wa.me')) {
      source = 'WhatsApp';
    } else if (content.contains('facebook') || content.contains('fb.com')) {
      source = 'Facebook';
    } else if (content.contains('instagram')) {
      source = 'Instagram';
    } else if (content.contains('twitter') || content.contains('x.com')) {
      source = 'Twitter/X';
    } else {
      source = 'Link Direto';
    }

    // Análise simulada baseada em padrões conhecidos de fake news
    final lowerContent = content.toLowerCase();
    
    if (_containsFakeNewsPatterns(lowerContent)) {
      status = VerificationStatus.fakeNews;
      confidence = 85 + (DateTime.now().millisecond % 15);
      details = 'Conteúdo identificado como potencialmente falso. Padrões de desinformação detectados.';
    } else if (_containsSuspiciousPatterns(lowerContent)) {
      status = VerificationStatus.suspicious;
      confidence = 60 + (DateTime.now().millisecond % 20);
      details = 'Conteúdo requer verificação adicional. Algumas informações não puderam ser confirmadas.';
    } else if (_containsTrustedSources(lowerContent)) {
      status = VerificationStatus.verified;
      confidence = 90 + (DateTime.now().millisecond % 10);
      details = 'Conteúdo verificado como autêntico. Fonte confiável identificada.';
    } else {
      status = VerificationStatus.suspicious;
      confidence = 50 + (DateTime.now().millisecond % 30);
      details = 'Não foi possível verificar completamente. Recomendamos cautela ao compartilhar.';
    }

    final verification = VerificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
      source: source,
      verifiedAt: DateTime.now(),
      status: status,
      confidence: confidence,
      details: details,
    );

    _userVerifications.insert(0, verification);
    return verification;
  }

  bool _containsFakeNewsPatterns(String content) {
    final patterns = [
      'milagroso',
      'cura secreta',
      'governo esconde',
      'urgente compartilhe',
      'não querem que você saiba',
      'descoberta incrível',
      'médicos não contam',
      'ganhe dinheiro fácil',
      'promoção imperdível',
    ];
    return patterns.any((p) => content.contains(p));
  }

  bool _containsSuspiciousPatterns(String content) {
    final patterns = [
      'dizem que',
      'fontes anônimas',
      'não confirmado',
      'boato',
      'será verdade',
    ];
    return patterns.any((p) => content.contains(p));
  }

  bool _containsTrustedSources(String content) {
    final sources = [
      'gov.br',
      'agenciabrasil',
      'g1.globo',
      'uol.com.br',
      'folha.uol',
      'estadao',
      'fiocruz',
      'inpe',
      'ibge',
    ];
    return sources.any((s) => content.contains(s));
  }

  // Obter estatísticas do usuário
  Future<UserStats> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = await getUserVerifications();
    
    return UserStats(
      totalVerifications: all.length,
      verified: all.where((v) => v.status == VerificationStatus.verified).length,
      fakeNews: all.where((v) => v.status == VerificationStatus.fakeNews).length,
      suspicious: all.where((v) => v.status == VerificationStatus.suspicious).length,
    );
  }
}
