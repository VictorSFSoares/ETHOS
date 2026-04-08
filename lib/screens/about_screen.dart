import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF4CAF50), size: 24),
            SizedBox(width: 8),
            Text(
              'Sobre o ETHOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLogoSection(),
            const SizedBox(height: 32),
            _buildStorySection(),
            const SizedBox(height: 24),
            _buildMissionSection(),
            const SizedBox(height: 24),
            _buildValuesSection(),
            const SizedBox(height: 24),
            _buildTeamSection(),
            const SizedBox(height: 24),
            _buildAwardsSection(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 32),
            _buildVersionInfo(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.2),
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.verified,
              color: Color(0xFF4CAF50),
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ETHOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Portal de Verificação',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Combatendo a desinformacao desde 2024',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return _buildSection(
      icon: Icons.auto_stories,
      title: 'Nossa Historia',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A historia do ETHOS comecou em uma noite chuvosa de marco de 2024, quando quatro estudantes de jornalismo da Universidade de Sao Paulo se reuniram em um pequeno apartamento no bairro de Pinheiros.',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Marina Santos, uma jovem de 23 anos apaixonada por investigacao, havia perdido sua avo para um golpe baseado em fake news sobre tratamentos milagrosos. Determinada a evitar que outras familias passassem pelo mesmo sofrimento, ela convocou seus amigos Pedro, Lucas e Ana para criar algo que pudesse fazer a diferenca.',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Com apenas R\$ 500 em uma vaquinha entre amigos e muitas noites sem dormir, nasceu o ETHOS - nome escolhido em homenagem ao termo grego que significa "carater" e "credibilidade". O primeiro escritorio foi a mesa da cozinha de Marina.',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Text(
            'O grande momento veio durante as eleicoes de 2024, quando o ETHOS desmascarou uma rede de desinformacao que atingia milhoes de brasileiros. A reportagem viralizou, e em uma semana o aplicativo saltou de 5.000 para 500.000 usuarios.',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Hoje, dois anos depois, o ETHOS conta com uma equipe de mais de 50 jornalistas e verificadores espalhados por todo o Brasil, ja verificou mais de 2 milhoes de noticias e se tornou referencia nacional no combate a desinformacao. Mas Marina ainda faz questao de responder pessoalmente algumas mensagens de usuarios - especialmente aquelas de pessoas que, como ela, perderam alguem querido para as fake news.',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote,
                  color: Color(0xFF4CAF50),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '"A verdade e o unico antidoto contra o medo."',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '- Marina Santos, Fundadora do ETHOS',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return _buildSection(
      icon: Icons.flag,
      title: 'Nossa Missao',
      child: Text(
        'Democratizar o acesso a informacao verificada e empoderar os cidadaos brasileiros para que possam identificar e combater a desinformacao. Acreditamos que uma sociedade bem informada e o alicerce de uma democracia forte.',
        style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _buildValuesSection() {
    return _buildSection(
      icon: Icons.diamond,
      title: 'Nossos Valores',
      child: Column(
        children: [
          _buildValueItem(
            Icons.search,
            'Verdade',
            'Compromisso inabalavel com a apuracao rigorosa dos fatos.',
          ),
          _buildValueItem(
            Icons.visibility,
            'Transparencia',
            'Metodologia aberta e fontes sempre citadas.',
          ),
          _buildValueItem(
            Icons.balance,
            'Imparcialidade',
            'Verificamos fatos, nao opinioes ou posicoes politicas.',
          ),
          _buildValueItem(
            Icons.speed,
            'Agilidade',
            'Respostas rapidas para combater a velocidade das fake news.',
          ),
          _buildValueItem(
            Icons.people,
            'Acessibilidade',
            'Informacao verificada gratuita para todos os brasileiros.',
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return _buildSection(
      icon: Icons.groups,
      title: 'Equipe Fundadora',
      child: Column(
        children: [
          _buildTeamMember(
            'Marina Santos',
            'CEO & Fundadora',
            'Jornalista investigativa com 8 anos de experiencia.',
          ),
          _buildTeamMember(
            'Pedro Oliveira',
            'CTO',
            'Engenheiro de software especialista em IA e machine learning.',
          ),
          _buildTeamMember(
            'Lucas Ferreira',
            'Editor-Chefe',
            'Ex-editor do maior jornal do pais, 15 anos de carreira.',
          ),
          _buildTeamMember(
            'Ana Beatriz Costa',
            'Diretora de Parcerias',
            'Especialista em relacoes institucionais e terceiro setor.',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, String bio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardsSection() {
    return _buildSection(
      icon: Icons.emoji_events,
      title: 'Reconhecimentos',
      child: Column(
        children: [
          _buildAwardItem(
            '2024',
            'Premio Jornalismo Digital',
            'Associacao Brasileira de Jornalismo',
          ),
          _buildAwardItem(
            '2024',
            'Top 10 Startups de Impacto',
            'Revista Exame',
          ),
          _buildAwardItem(
            '2025',
            'Premio de Inovacao em Combate a Desinformacao',
            'Google News Initiative',
          ),
          _buildAwardItem(
            '2025',
            'Selo de Verificador Confiavel',
            'International Fact-Checking Network',
          ),
          _buildAwardItem(
            '2026',
            'Aplicativo do Ano - Categoria Utilidade',
            'Google Play Awards Brasil',
          ),
        ],
      ),
    );
  }

  Widget _buildAwardItem(String year, String title, String organization) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              year,
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  organization,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return _buildSection(
      icon: Icons.analytics,
      title: 'ETHOS em Numeros',
      child: Row(
        children: [
          Expanded(child: _buildStatItem('2M+', 'Verificacoes')),
          Expanded(child: _buildStatItem('5M+', 'Usuarios')),
          Expanded(child: _buildStatItem('50+', 'Jornalistas')),
          Expanded(child: _buildStatItem('27', 'Estados')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      icon: Icons.contact_mail,
      title: 'Contato',
      child: Column(
        children: [
          _buildContactItem(Icons.email, 'contato@ethos.app'),
          _buildContactItem(Icons.phone, '+55 (11) 99999-9999'),
          _buildContactItem(Icons.location_on, 'Sao Paulo, SP - Brasil'),
          _buildContactItem(Icons.language, 'www.ethos.app'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.camera_alt),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.alternate_email),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.play_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
      child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'ETHOS v1.0.0',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Feito com amor no Brasil',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          '2024-2026 ETHOS Tecnologia Ltda.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
