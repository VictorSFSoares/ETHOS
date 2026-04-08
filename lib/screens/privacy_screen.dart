import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _dataCollection = true;
  bool _analytics = true;
  bool _personalizedAds = false;
  bool _shareData = false;
  bool _twoFactorAuth = false;
  bool _biometricAuth = false;
  
  int _selectedTab = 0;

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
              'Privacidade e Segurança',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0 ? _buildPrivacyContent() : _buildPolicyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? const Color(0xFF4CAF50) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Configurações',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? const Color(0xFF4CAF50) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Políticas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Privacidade de Dados'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.data_usage,
              title: 'Coleta de Dados',
              subtitle: 'Permitir coleta de dados de uso para melhorar o app',
              value: _dataCollection,
              onChanged: (value) => setState(() => _dataCollection = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.analytics,
              title: 'Análises',
              subtitle: 'Compartilhar dados anônimos para análise',
              value: _analytics,
              onChanged: (value) => setState(() => _analytics = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.ads_click,
              title: 'Anúncios Personalizados',
              subtitle: 'Receber anúncios baseados em seus interesses',
              value: _personalizedAds,
              onChanged: (value) => setState(() => _personalizedAds = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.share,
              title: 'Compartilhar Dados',
              subtitle: 'Compartilhar dados com parceiros',
              value: _shareData,
              onChanged: (value) => setState(() => _shareData = value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Segurança'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.security,
              title: 'Autenticação em Duas Etapas',
              subtitle: 'Adicionar uma camada extra de segurança',
              value: _twoFactorAuth,
              onChanged: (value) => setState(() => _twoFactorAuth = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Autenticação Biométrica',
              subtitle: 'Usar impressão digital ou reconhecimento facial',
              value: _biometricAuth,
              onChanged: (value) => setState(() => _biometricAuth = value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Ações'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildActionTile(
              icon: Icons.download,
              title: 'Baixar Meus Dados',
              subtitle: 'Exportar todos os seus dados em formato JSON',
              onTap: () => _showDownloadDataDialog(),
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.delete_forever,
              title: 'Excluir Minha Conta',
              subtitle: 'Remover permanentemente sua conta e dados',
              onTap: () => _showDeleteAccountDialog(),
              isDestructive: true,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPolicyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicySection(
            'Política de Privacidade',
            '''
A ETHOS valoriza sua privacidade e está comprometida em proteger seus dados pessoais. Esta política descreve como coletamos, usamos e protegemos suas informações.

1. COLETA DE DADOS
Coletamos apenas os dados necessários para fornecer nossos serviços, incluindo:
- Informações de cadastro (nome, e-mail)
- Histórico de verificações realizadas
- Dados de uso do aplicativo
- Informações do dispositivo

2. USO DOS DADOS
Seus dados são utilizados para:
- Fornecer e melhorar nossos serviços
- Personalizar sua experiência
- Enviar notificações relevantes
- Desenvolver novos recursos

3. COMPARTILHAMENTO
Não vendemos seus dados. Compartilhamos informações apenas:
- Com seu consentimento explícito
- Para cumprir obrigações legais
- Com parceiros de serviço sob contratos de confidencialidade

4. SEGURANÇA
Implementamos medidas técnicas e organizacionais para proteger seus dados contra acesso não autorizado, alteração, divulgação ou destruição.

5. SEUS DIREITOS
Você tem direito a:
- Acessar seus dados pessoais
- Corrigir informações incorretas
- Solicitar exclusão de dados
- Exportar seus dados
- Revogar consentimentos
            ''',
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            'Termos de Uso',
            '''
Ao utilizar o ETHOS, você concorda com os seguintes termos:

1. ACEITAÇÃO
Ao acessar ou usar o aplicativo ETHOS, você concorda em cumprir estes termos de uso e todas as leis e regulamentos aplicáveis.

2. USO PERMITIDO
O ETHOS é uma ferramenta de verificação de informações. Você concorda em:
- Usar o serviço apenas para fins legais
- Não tentar manipular ou contornar nossos sistemas
- Não usar o serviço para disseminar desinformação
- Respeitar os direitos de propriedade intelectual

3. CONTA DE USUÁRIO
Você é responsável por:
- Manter a confidencialidade de sua senha
- Todas as atividades em sua conta
- Notificar imediatamente sobre uso não autorizado

4. CONTEÚDO
As verificações realizadas pelo ETHOS são baseadas em análises de nossa equipe e fontes confiáveis. No entanto:
- Não garantimos precisão absoluta
- As informações são fornecidas "como estão"
- Recomendamos sempre consultar múltiplas fontes

5. LIMITAÇÃO DE RESPONSABILIDADE
O ETHOS não se responsabiliza por:
- Decisões tomadas com base em nossas verificações
- Interrupções no serviço
- Danos indiretos ou consequentes

6. MODIFICAÇÕES
Reservamos o direito de modificar estes termos a qualquer momento. Alterações significativas serão comunicadas por e-mail ou notificação no app.
            ''',
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            'Política de Cookies',
            '''
O ETHOS utiliza cookies e tecnologias similares para melhorar sua experiência.

1. O QUE SÃO COOKIES
Cookies são pequenos arquivos armazenados em seu dispositivo que nos ajudam a reconhecê-lo e lembrar suas preferências.

2. TIPOS DE COOKIES UTILIZADOS

Cookies Essenciais:
- Necessários para o funcionamento básico
- Não podem ser desativados

Cookies de Desempenho:
- Coletam informações sobre uso
- Ajudam a melhorar o aplicativo

Cookies de Funcionalidade:
- Lembram suas preferências
- Personalizam sua experiência

3. GERENCIAMENTO
Você pode gerenciar cookies através das configurações de privacidade do app ou do seu navegador.

4. CONSENTIMENTO
Ao continuar usando o ETHOS, você consente com o uso de cookies conforme descrito nesta política.
            ''',
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            'Lei Geral de Proteção de Dados (LGPD)',
            '''
Em conformidade com a Lei nº 13.709/2018 (LGPD), informamos:

1. CONTROLADOR DE DADOS
ETHOS Tecnologia Ltda.
CNPJ: 00.000.000/0001-00
Endereço: São Paulo, SP, Brasil

2. ENCARREGADO DE DADOS (DPO)
E-mail: privacidade@ethos.app
Telefone: (11) 0000-0000

3. BASE LEGAL
O tratamento de seus dados é realizado com base em:
- Consentimento do titular
- Execução de contrato
- Cumprimento de obrigação legal
- Interesse legítimo

4. DIREITOS DO TITULAR
Conforme a LGPD, você tem direito a:
- Confirmação da existência de tratamento
- Acesso aos dados
- Correção de dados incompletos ou desatualizados
- Anonimização, bloqueio ou eliminação
- Portabilidade dos dados
- Revogação do consentimento

5. COMO EXERCER SEUS DIREITOS
Para exercer seus direitos, entre em contato através do e-mail privacidade@ethos.app ou utilize as opções disponíveis na seção "Configurações" do aplicativo.

6. TRANSFERÊNCIA INTERNACIONAL
Seus dados podem ser transferidos para servidores localizados fora do Brasil, sempre com níveis adequados de proteção.
            ''',
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Última atualização: 08 de Abril de 2026',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? Colors.red : const Color(0xFF4CAF50)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF4CAF50),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey.shade600,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade800, indent: 56);
  }

  Widget _buildPolicySection(String title, String content) {
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
              const Icon(Icons.description, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content.trim(),
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Baixar Meus Dados', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Seus dados serão exportados em formato JSON e enviados para seu e-mail cadastrado. O processo pode levar até 24 horas.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                      SizedBox(width: 12),
                      Expanded(child: Text('Solicitação enviada! Você receberá um e-mail em breve.')),
                    ],
                  ),
                  backgroundColor: Color(0xFF1A1A1A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Solicitar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Excluir Conta', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Esta ação é irreversível. Todos os seus dados, histórico de verificações e conquistas serão permanentemente excluídos.\n\nTem certeza que deseja continuar?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(child: Text('Solicitação de exclusão enviada. Sua conta será removida em 30 dias.')),
                    ],
                  ),
                  backgroundColor: Color(0xFF1A1A1A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
