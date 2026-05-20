import 'package:tamago/utils/services/api_manager.dart'; // Your ApiClient file
import 'package:tamago/utils/services/auth_service.dart';
import 'package:tamago/utils/services/game_service.dart';
import 'package:tamago/utils/services/chat_service.dart';
import 'package:tamago/utils/services/friend_service.dart'; // Import your friend service
import 'package:tamago/utils/services/store_service.dart';

class ServiceLocator {
  // Single instance of the network client
  final ApiClient _apiClient = ApiClient();

  // Room-specific services
  late final AuthService auth;
  late final GameService game;
  late final ChatService chat;
  late final FriendService friend;
  //late final StoreService store;
  // late final MinigameService minigame; // Ready for expansion

  ServiceLocator() {
    // Inject the same apiClient instance into everything
    auth = AuthService(_apiClient);
    game = GameService(_apiClient);
    chat = ChatService(_apiClient);
    friend = FriendService(_apiClient);
 //   store = StoreService(_apiClient);
  }
}

// Global instance (or use Provider/GetIt to manage this)
final services = ServiceLocator();