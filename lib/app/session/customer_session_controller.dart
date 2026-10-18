import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/session/session_client.dart';
import '../../core/storage/token_store.dart';
import '../../core/storage/secure_token_store.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

/// Application composition; authentication behavior lives in its feature.
class CustomerSessionController extends AuthController {
  CustomerSessionController({
    required String baseUrl,
    http.Client? client,
    TokenStore? store,
  }) : super(
         SessionClient(
           transport: ApiClient(baseUrl: baseUrl, client: client),
           store: store ?? SecureTokenStore(),
           accountGroup: 'Customer',
         ),
       );
}
