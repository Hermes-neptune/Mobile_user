import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String configUrl =
      'https://hermes-neptune.github.io/site-sistema-Redirecionamento/api.json';

  static String? _cachedBaseUrl;
  static DateTime? _lastFetch;
  static const Duration cacheExpiration = Duration(minutes: 30);
  static bool _isInitialized = false;

  static const String baseRoot = '/site-sistema-git/site-sistema/api/user/';

  static const String loginEndpoint = 'login.php';
  static const String registerEndpoint = 'register.php';
  static const String profileEndpoint = 'profile.php';
  static const String friendsEndpoint = 'friends.php';
  static const String noticesEndpoint = 'notices.php';
  static const String featuredGameEndpoint = 'featured_game.php';
  static const String popularGamesEndpoint = 'popular_games.php';
  static const String configEndpoint =
      '/site-sistema-git/site-sistema/login.php?redirect=config.php';
  static const String forgotPasswordEndpoint = 'forgot_password.php';
  static const String conversationsEndpoint = 'get_conversations.php';
  static const String getPreEndpoint =
      '/site-sistema-git/site-sistema/api/adm/get_preferences.php';
  static const String updatePreEndpoint =
      '/site-sistema-git/site-sistema/api/adm/update_preferences.php';
  static const String fetchMessagesEndpoint = 'fetch_messages.php';
  static const String sendMessageEndpoint = 'send_message.php';
  static const String getMedalhasEndpoint = 'get_medalhas.php';
  static const String createGroupEndpoint = 'create_group.php';
  static const String inviteGroupEndpoint = 'invite_group.php';
  static const String sendMessagesGroupEndpoint = 'send_messages_group.php';
  static const String infoGroupEndpoint = 'info_group.php';
  static const String leaveGroupEndpoint = 'leave_group.php';
  static const String deleteGroupEndpoint = 'delete_group.php';
  static const String searchUserEndpoint = 'search_user.php';
  static const String searchForGroupEndpoint = 'search_for_group.php';
  static const String groupMembersEndpoint = 'group_members.php';
  static const String groupEndpoint = 'group.php';
  static const String groupRequestEndpoint = 'group_request.php';
  static const String friendRequestEndpoint = 'friend_request.php';
  static const String messageGroupEndpoint = 'messages_group.php';

  static Future<void> initialize() async {
    if (_isInitialized &&
        _cachedBaseUrl != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < cacheExpiration) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(configUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success' && data['link'] != null) {
          _cachedBaseUrl = data['link'].toString().trim();
          _lastFetch = DateTime.now();
          _isInitialized = true;
        } else {
          throw Exception('Formato JSON inválido ou status não é success');
        }
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar baseUrl: $e');
      _cachedBaseUrl = 'https://91d0f82d23ff.ngrok-free.app';
      _isInitialized = true;
    }
  }

  static String get baseUrl {
    if (!_isInitialized || _cachedBaseUrl == null) {
      return 'https://91d0f82d23ff.ngrok-free.app';
    }
    return _cachedBaseUrl!;
  }

  static void clearCache() {
    _cachedBaseUrl = null;
    _lastFetch = null;
    _isInitialized = false;
  }

  static Future<void> refresh() async {
    clearCache();
    await initialize();
  }

  static String get loginUrl => '$baseUrl$baseRoot$loginEndpoint';

  static String get forgotPasswordUrl =>
      '$baseUrl$baseRoot$forgotPasswordEndpoint';

  static String get registerUrl => '$baseUrl$registerEndpoint';

  static String get profileUrl => '$baseUrl$baseRoot$profileEndpoint';

  static String get friendsUrl => '$baseUrl$baseRoot$friendsEndpoint';

  static String get noticesUrl => '$baseUrl$baseRoot$noticesEndpoint';

  static String get featuredGameUrl => '$baseUrl$baseRoot$featuredGameEndpoint';

  static String get popularGamesUrl => '$baseUrl$baseRoot$popularGamesEndpoint';

  static String get configUrlComplete => '$baseUrl$configEndpoint';

  static String get conversationsUrl =>
      '$baseUrl$baseRoot$conversationsEndpoint';

  static String get getPreferencesURL => '$baseUrl$getPreEndpoint';

  static String get updatePreferencesURL => '$baseUrl$updatePreEndpoint';

  static String get fetchMessagesURL =>
      '$baseUrl$baseRoot$fetchMessagesEndpoint';

  static String get sendMessageURL => '$baseUrl$baseRoot$sendMessageEndpoint';

  static String get getMedalhasURL => '$baseUrl$baseRoot$getMedalhasEndpoint';

  static String get createGroupURL => '$baseUrl$baseRoot$createGroupEndpoint';

  static String get inviteGroupURL => '$baseUrl$baseRoot$inviteGroupEndpoint';

  static String get sendMessagesGroupURL =>
      '$baseUrl$baseRoot$sendMessagesGroupEndpoint';

  static String get infoGroupURL => '$baseUrl$baseRoot$infoGroupEndpoint';

  static String get leaveGroupURL => '$baseUrl$baseRoot$leaveGroupEndpoint';

  static String get deleteGroupURL => '$baseUrl$baseRoot$deleteGroupEndpoint';

  static String get searchUserURL => '$baseUrl$baseRoot$searchUserEndpoint';

  static String get searchForGroupURL =>
      '$baseUrl$baseRoot$searchForGroupEndpoint';

  static String get groupMembersURL => '$baseUrl$baseRoot$groupMembersEndpoint';

  static String get groupURL => '$baseUrl$baseRoot$groupEndpoint';

  static String get groupRequestURL => '$baseUrl$baseRoot$groupRequestEndpoint';

  static String get friendRequestURL =>
      '$baseUrl$baseRoot$friendRequestEndpoint';
  static String get messageGroupURL => '$baseUrl$baseRoot$messageGroupEndpoint';

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };
}
