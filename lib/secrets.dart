// Este arquivo NÃO deve ser versionado no git!
// Adicione 'lib/secrets.dart' ao seu .gitignore
// Coloque aqui sua chave de API do Google Gemini (Vertex AI, Gemini-pro, etc)
// Use variável de ambiente ou arquivo .env para a chave Google API
const String googleApiKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');
