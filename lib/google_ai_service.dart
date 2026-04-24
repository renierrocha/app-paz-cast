import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleAIService {
  final String apiKey;
  GoogleAIService(this.apiKey);

  Future<String> explainVerse(String verse) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-2.5-pro:generateContent?key=$apiKey');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Explique e resuma o seguinte versículo bíblico de forma clara e prática para leigos: "$verse"'
              }
            ]
          }
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text']?.trim() ?? 'Sem resposta.';
    } else {
      return 'Erro ao consultar IA Google: ${response.body}';
    }
  }
}
