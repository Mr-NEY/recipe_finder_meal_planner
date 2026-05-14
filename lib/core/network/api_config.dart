class ApiConfig {
  const ApiConfig._();

  static const baseUrl = 'https://api.spoonacular.com';
  static const apiKey = String.fromEnvironment('SPOONACULAR_API_KEY');

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
