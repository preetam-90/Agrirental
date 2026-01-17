import 'package:connectivity_plus/connectivity_plus.dart';

/// Network info to check connectivity status
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfoImpl(this.connectivity);
  
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }
  
  @override
  Stream<bool> get connectionStream {
    return connectivity.onConnectivityChanged.map(_isConnectedResult);
  }
  
  bool _isConnectedResult(List<ConnectivityResult> results) {
    // Connected if any result is not none
    return results.any((result) => 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );
  }
}
