class AstrologerReview {
  final String userId;
  final int rating;
  final String astrologerId;
  final bool isActive;
  final bool isPublic;
  final String updatedAt;
  final String modifiedBy;
  final int id;
  final String review;
  final String? reply;
  final bool isDelete;
  final String createdAt;
  final String createdBy;

  AstrologerReview({
    required this.userId,
    required this.rating,
    required this.astrologerId,
    required this.isActive,
    required this.isPublic,
    required this.updatedAt,
    required this.modifiedBy,
    required this.id,
    required this.review,
    this.reply,
    required this.isDelete,
    required this.createdAt,
    required this.createdBy,
  });

  factory AstrologerReview.fromJson(Map<String, dynamic> json) {
    return AstrologerReview(
      userId: json['userId'] ?? '',
      rating: json['rating'] ?? 0,
      astrologerId: json['astrologerId'] ?? '',
      isActive: json['isActive'] ?? false,
      isPublic: json['isPublic'] ?? false,
      updatedAt: json['updated_at'] ?? '',
      modifiedBy: json['modifiedBy'] ?? '',
      id: json['id'] ?? 0,
      review: json['review'] ?? '',
      reply: json['reply'],
      isDelete: json['isDelete'] ?? false,
      createdAt: json['created_at'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'rating': rating,
      'astrologerId': astrologerId,
      'isActive': isActive,
      'isPublic': isPublic,
      'updated_at': updatedAt,
      'modifiedBy': modifiedBy,
      'id': id,
      'review': review,
      'reply': reply,
      'isDelete': isDelete,
      'created_at': createdAt,
      'createdBy': createdBy,
    };
  }
}