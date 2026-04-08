class ProxySettings {
  final String host;
  final int port;

  final String? login;
  final String? password;

  ProxySettings({
    required this.host,
    required this.port,
    this.login,
    this.password,
  });

  bool get requiresAuth => login != null && password != null;

  @override
  String toString() =>
      "ProxySettings(host: $host, port: $port, ${login != null ? "login: $login" : ""}";
}
