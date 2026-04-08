import 'package:flutter/material.dart';

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'O que é o ETHOS?',
      answer: 'O ETHOS é um aplicativo de verificação de notícias e fact-checking desenvolvido para combater a desinformação. Nossa equipe de especialistas analisa conteúdos suspeitos e fornece classificações confiáveis sobre a veracidade das informações.',
    ),
    FAQItem(
      question: 'Como verificar uma notícia?',
      answer: 'Para verificar uma notícia, vá até a Central de Verificação (tela inicial) e escolha o tipo de conteúdo que deseja verificar: Link, Texto, Imagem ou Áudio. Cole ou carregue o conteúdo e aguarde a análise. Você receberá um resultado indicando se a informação é verdadeira, falsa ou suspeita.',
    ),
    FAQItem(
      question: 'Quanto tempo leva uma verificação?',
      answer: 'A maioria das verificações é concluída em segundos, pois nosso sistema compara o conteúdo com nossa base de dados de verificações anteriores. Conteúdos novos podem levar mais tempo, pois são analisados por nossa equipe de fact-checkers.',
    ),
    FAQItem(
      question: 'As verificações são confiáveis?',
      answer: 'Sim! Nossa equipe segue metodologia rigorosa de verificação, consultando fontes oficiais, especialistas e documentos. Todas as verificações passam por revisão antes de serem publicadas. Nosso compromisso é com a verdade e a transparência.',
    ),
    FAQItem(
      question: 'O que significam as classificações?',
      answer: 'VERDADEIRO (verde): A informação foi verificada e está correta.\nFALSO (vermelho): A informação é incorreta ou enganosa.\nSUSPEITO (laranja): A informação pode ser parcialmente verdadeira ou requer cautela.\nNÃO VERIFICADO (cinza): Ainda não há verificação disponível.',
    ),
    FAQItem(
      question: 'Posso sugerir conteúdos para verificação?',
      answer: 'Sim! Qualquer conteúdo que você submeter e que ainda não esteja em nossa base será encaminhado para análise da nossa equipe. Você receberá uma notificação quando a verificação for concluída.',
    ),
    FAQItem(
      question: 'Como funcionam as conquistas?',
      answer: 'As conquistas são premiações que você recebe ao usar o ETHOS. Você pode desbloquear conquistas verificando notícias, identificando fake news, mantendo uma sequência de uso diário e muito mais. Acesse seu Perfil para ver suas conquistas.',
    ),
    FAQItem(
      question: 'Meus dados estão seguros?',
      answer: 'Absolutamente! Levamos a segurança muito a sério. Seus dados são criptografados e armazenados em servidores seguros. Não vendemos informações para terceiros. Você pode consultar nossa Política de Privacidade para mais detalhes.',
    ),
    FAQItem(
      question: 'Como excluir minha conta?',
      answer: 'Para excluir sua conta, acesse Perfil > Privacidade e Segurança > Excluir Minha Conta. Lembre-se que esta ação é irreversível e todos os seus dados serão permanentemente removidos.',
    ),
    FAQItem(
      question: 'O ETHOS é gratuito?',
      answer: 'Sim! O ETHOS é totalmente gratuito. Nossa missão é democratizar o acesso à informação verificada. Não há planos pagos ou recursos premium bloqueados.',
    ),
    FAQItem(
      question: 'Como entrar em contato com o suporte?',
      answer: 'Você pode entrar em contato conosco através do chat de suporte nesta mesma tela (aba "Suporte"). Nossa equipe responde em até 24 horas úteis.',
    ),
    FAQItem(
      question: 'O ETHOS funciona offline?',
      answer: 'O ETHOS requer conexão com a internet para realizar verificações, pois precisa acessar nossa base de dados em tempo real. No entanto, você pode visualizar seu histórico de verificações anteriores offline.',
    ),
  ];

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
              'Ajuda e Suporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4CAF50),
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Perguntas Frequentes'),
            Tab(text: 'Suporte'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildSupportTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqItems.length,
      itemBuilder: (context, index) {
        return _buildFAQCard(_faqItems[index], index);
      },
    );
  }

  Widget _buildFAQCard(FAQItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isExpanded
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : Colors.grey.shade800,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: item.isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              item.isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.isExpanded ? Icons.help : Icons.help_outline,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          title: Text(
            item.question,
            style: TextStyle(
              color: item.isExpanded ? const Color(0xFF4CAF50) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: AnimatedRotation(
            turns: item.isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: item.isExpanded ? const Color(0xFF4CAF50) : Colors.grey,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.answer,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTab() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyChatState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fale com nossa equipe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Envie sua mensagem e nossa equipe responderá o mais breve possível.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickQuestion('Tenho uma dúvida'),
                _buildQuickQuestion('Reportar um bug'),
                _buildQuickQuestion('Sugerir melhoria'),
                _buildQuickQuestion('Problema com verificação'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestion(String text) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Color(0xFF4CAF50),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Equipe ETHOS',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.black : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.time),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        time: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: 'Sua mensagem foi enviada, retornaremos assim que possível.',
          isUser: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
