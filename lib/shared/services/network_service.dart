import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();

  NetworkService._internal();

  factory NetworkService() => _instance;

  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onOnlineChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  bool _hasConnection(List<ConnectivityResult> result) {
    return result.any((item) => item != ConnectivityResult.none);
  }
}
