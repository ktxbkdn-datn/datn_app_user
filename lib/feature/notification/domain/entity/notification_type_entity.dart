class NotificationType {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String? createdAt;

  NotificationType({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.createdAt,
  });

  NotificationType copyWith({
    int? id,
    String? name,
    String? description,
    String? status,
    String? createdAt,
  }) {
    return NotificationType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}