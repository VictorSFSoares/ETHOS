import '../models/data_models.dart';

/// Serviço de Notícias - Dados fornecidos pela equipe ETHOS
/// Este serviço simula uma API de notícias brasileiras verificadas
/// Os dados são curados e verificados pela nossa equipe de fact-checkers
class NewsService {
  // Singleton
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  // Categorias disponíveis
  static const List<String> categories = [
    'Todas',
    'Política',
    'Saúde',
    'Tecnologia',
    'Economia',
    'Educação',
    'Meio Ambiente',
  ];

  // Banco de notícias verificadas pela equipe ETHOS
  final List<NewsItem> _newsDatabase = [
    // Política
    NewsItem(
      id: '1',
      title: 'Governo anuncia novas medidas econômicas para 2026',
      description: 'Pacote inclui redução de impostos para pequenas empresas e incentivos fiscais para setores estratégicos da economia brasileira.',
      imageUrl: 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?w=800',
      source: 'Agência Brasil',
      category: 'Política',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: VerificationStatus.verified,
      confidence: 98,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '2',
      title: 'Senado aprova projeto de lei sobre segurança digital',
      description: 'Nova legislação estabelece diretrizes para proteção de dados pessoais e combate a crimes cibernéticos no país.',
      imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
      source: 'Senado Notícias',
      category: 'Política',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: VerificationStatus.verified,
      confidence: 95,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '3',
      title: 'TSE divulga calendário das eleições municipais',
      description: 'Tribunal Superior Eleitoral confirma datas e regras para o pleito de outubro.',
      imageUrl: 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?w=800',
      source: 'TSE',
      category: 'Política',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: VerificationStatus.verified,
      confidence: 100,
      author: 'Equipe ETHOS',
    ),

    // Saúde
    NewsItem(
      id: '4',
      title: 'Nova vacina contra dengue apresenta 95% de eficácia em testes clínicos',
      description: 'Estudo conduzido em parceria com a Fiocruz mostra resultados promissores para imunização da população brasileira.',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      source: 'Fiocruz',
      category: 'Saúde',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: VerificationStatus.verified,
      confidence: 97,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '5',
      title: 'Ministério da Saúde amplia programa de saúde mental',
      description: 'Novos centros de atendimento psicológico serão instalados em todas as capitais brasileiras até o final do ano.',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      source: 'Ministério da Saúde',
      category: 'Saúde',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      status: VerificationStatus.verified,
      confidence: 94,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '6',
      title: 'SUS passa a oferecer novo tratamento para diabetes tipo 2',
      description: 'Medicamento de última geração será distribuído gratuitamente para pacientes cadastrados no sistema público de saúde.',
      imageUrl: 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=800',
      source: 'ANS',
      category: 'Saúde',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: VerificationStatus.verified,
      confidence: 96,
      author: 'Equipe ETHOS',
    ),

    // Tecnologia
    NewsItem(
      id: '7',
      title: 'Inteligência Artificial revoluciona diagnósticos médicos no Brasil',
      description: 'Hospitais públicos começam a adotar sistemas de IA para triagem de pacientes, reduzindo tempo de espera em até 60%.',
      imageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
      source: 'Folha de SP',
      category: 'Tecnologia',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: VerificationStatus.verified,
      confidence: 92,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '8',
      title: 'Brasil lança satélite para monitoramento da Amazônia',
      description: 'Novo equipamento permitirá detecção em tempo real de desmatamento e queimadas na região amazônica.',
      imageUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800',
      source: 'INPE',
      category: 'Tecnologia',
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      status: VerificationStatus.verified,
      confidence: 99,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '9',
      title: 'Startup brasileira desenvolve bateria com 5x mais duração',
      description: 'Tecnologia nacional promete revolucionar mercado de veículos elétricos e dispositivos móveis.',
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      source: 'Exame',
      category: 'Tecnologia',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: VerificationStatus.verified,
      confidence: 88,
      author: 'Equipe ETHOS',
    ),

    // Economia
    NewsItem(
      id: '10',
      title: 'Banco Central mantém taxa Selic em 10,5% ao ano',
      description: 'Decisão do Copom considera cenário de inflação controlada e crescimento econômico estável.',
      imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800',
      source: 'Banco Central',
      category: 'Economia',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: VerificationStatus.verified,
      confidence: 100,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '11',
      title: 'PIB brasileiro cresce 2,8% no primeiro trimestre',
      description: 'Resultado supera expectativas do mercado e indica recuperação consistente da economia nacional.',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
      source: 'IBGE',
      category: 'Economia',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: VerificationStatus.verified,
      confidence: 100,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '12',
      title: 'Exportações brasileiras batem recorde histórico',
      description: 'Agronegócio e mineração lideram crescimento das vendas externas no acumulado do ano.',
      imageUrl: 'https://images.unsplash.com/photo-1578575437130-527eed3abbec?w=800',
      source: 'MDIC',
      category: 'Economia',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: VerificationStatus.verified,
      confidence: 97,
      author: 'Equipe ETHOS',
    ),

    // Educação
    NewsItem(
      id: '13',
      title: 'MEC anuncia expansão do programa de bolsas universitárias',
      description: 'Mais de 500 mil novas vagas serão oferecidas em universidades públicas e privadas para 2027.',
      imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
      source: 'MEC',
      category: 'Educação',
      publishedAt: DateTime.now().subtract(const Duration(hours: 7)),
      status: VerificationStatus.verified,
      confidence: 95,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '14',
      title: 'Brasil avança em ranking internacional de educação',
      description: 'País sobe 15 posições no PISA, com destaque para melhoria em matemática e ciências.',
      imageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
      source: 'OCDE',
      category: 'Educação',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      status: VerificationStatus.verified,
      confidence: 93,
      author: 'Equipe ETHOS',
    ),

    // Meio Ambiente
    NewsItem(
      id: '15',
      title: 'Desmatamento na Amazônia cai 40% em relação ao ano anterior',
      description: 'Dados do INPE mostram efetividade das políticas de fiscalização e preservação ambiental.',
      imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      source: 'INPE',
      category: 'Meio Ambiente',
      publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
      status: VerificationStatus.verified,
      confidence: 98,
      author: 'Equipe ETHOS',
    ),
    NewsItem(
      id: '16',
      title: 'Brasil inaugura maior usina solar da América Latina',
      description: 'Complexo em Minas Gerais terá capacidade para abastecer 1 milhão de residências.',
      imageUrl: 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800',
      source: 'ANEEL',
      category: 'Meio Ambiente',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: VerificationStatus.verified,
      confidence: 96,
      author: 'Equipe ETHOS',
    ),
  ];

  // Obter todas as notícias
  Future<List<NewsItem>> getAllNews() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_newsDatabase)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  // Obter notícias por categoria
  Future<List<NewsItem>> getNewsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category == 'Todas') {
      return getAllNews();
    }
    return _newsDatabase
        .where((news) => news.category == category)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  // Obter notícias em destaque (trending)
  Future<List<NewsItem>> getTrendingNews() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _newsDatabase
        .where((news) => news.confidence >= 95)
        .take(5)
        .toList();
  }

  // Buscar notícias
  Future<List<NewsItem>> searchNews(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _newsDatabase
        .where((news) =>
            news.title.toLowerCase().contains(lowerQuery) ||
            news.description.toLowerCase().contains(lowerQuery) ||
            news.source.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Obter notícia por ID
  Future<NewsItem?> getNewsById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _newsDatabase.firstWhere((news) => news.id == id);
    } catch (e) {
      return null;
    }
  }
}
