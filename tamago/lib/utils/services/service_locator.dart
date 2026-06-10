import 'package:tamago/utils/services/api_manager.dart'; 
import 'package:tamago/utils/services/auth_service.dart';
import 'package:tamago/utils/services/game_service.dart';
import 'package:tamago/utils/services/chat_service.dart';
import 'package:tamago/utils/services/friend_service.dart'; 
import 'package:tamago/utils/services/store_service.dart';
// 👇 ADD THIS IMPORT
import 'package:tamago/utils/services/tama_service.dart'; 

class ServiceLocator {
  final ApiClient _apiClient = ApiClient();

  late final AuthService auth;
  late final GameService game;
  late final ChatService chat;
  late final FriendService friend;
  late final StoreService store;
  // 👇 ADD THIS
  late final TamaService tama; 

  ServiceLocator() {
    auth = AuthService(_apiClient);
    game = GameService(_apiClient);
    chat = ChatService(_apiClient);
    friend = FriendService(_apiClient);
    store = StoreService(_apiClient);
    // 👇 ADD THIS
    tama = TamaService(_apiClient); 
  }
}

final services = ServiceLocator();