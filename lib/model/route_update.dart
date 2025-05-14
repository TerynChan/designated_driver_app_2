class RouteUpdate {
  final String title;
  final String description;
  final String? location;
  final String severity;
  final DateTime timestamp;
  final String source;

  RouteUpdate({
    required this.title,
    required this.description,
    this.location,
    required this.severity,
    required this.timestamp,
    required this.source,
  });
}