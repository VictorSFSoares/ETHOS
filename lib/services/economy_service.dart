import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/data_models.dart';

class EconomyService {
  // Padrão Singleton para otimizar memória
  static final EconomyService _instance = EconomyService._internal();
  factory EconomyService() => _instance;
  EconomyService._internal();

  // API do Mercado Financeiro (Gratuita e sem limites chatos)
  final String _apiUrl = 'https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL,BTC-BRL';

  Future<List<CurrencyRate>> getMarketRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Pega as 3 moedas específicas que pedimos na URL
        return [
          CurrencyRate.fromJson(data['USDBRL']),
          CurrencyRate.fromJson(data['EURBRL']),
          CurrencyRate.fromJson(data['BTCBRL']),
        ];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar cotações do mercado: $e');
      return [];
    }
  }
}