class ComplaintModel {
  final int? id;
  final String title;
  final String description;
  final String status;
  final String? location;
  final String? photo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final int? userId;

  ComplaintModel({
    this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.location,
    this.photo,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.userId,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'pending',
      location: json['location'] as String?,
      photo: json['photo'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'location': location,
      'photo': photo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'user_id': userId,
    };
  }
}
