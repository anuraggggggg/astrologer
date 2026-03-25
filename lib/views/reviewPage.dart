// Reviews Page - Updated to show user names and profile images
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Map<String, dynamic>> _reviews = [];
  Map<String, Map<String, String>> _userDetails = {}; // Cache for user details
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = FastApiServices();
      final reviews = await api.getAstrologerReviewsList();

      // Fetch user details for each review
      Map<String, Map<String, String>> tempUserDetails = {};

      for (var review in reviews) {
        final userId = review['userId'];
        if (userId != null && !tempUserDetails.containsKey(userId)) {
          try {
            final userDetails = await api.getCustomerDetails(userId);
            if (userDetails != null) {
              tempUserDetails[userId] = {
                'name': userDetails['name'] ?? 'Client',
                'profileImage': userDetails['profileImage'] ?? '',
              };
            } else {
              tempUserDetails[userId] = {
                'name': 'Client',
                'profileImage': '',
              };
            }
          } catch (e) {
            print('Error fetching user $userId: $e');
            tempUserDetails[userId] = {
              'name': 'Client',
              'profileImage': '',
            };
          }
        }
      }

      setState(() {
        _reviews = reviews;
        _userDetails = tempUserDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshReviews() async {
    await _loadReviews();
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Client') return 'C';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Your Reviews",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_reviews.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_reviews.length} reviews",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReviews,
        color: Colors.yellow.shade700,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Failed to load reviews",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReviews,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Try Again"),
                        ),
                      ],
                    ),
                  )
                : _reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No reviews yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Reviews from your clients will appear here",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Keep providing great service to get reviews!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.yellow.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          final userId = review['userId'] ?? '';
                          final userDetails = _userDetails[userId] ??
                              {
                                'name': 'Client',
                                'profileImage': '',
                              };
                          final userName = userDetails['name']!;
                          final profileImage = userDetails['profileImage']!;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Profile Image or Initials Circle
                                    profileImage.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 24,
                                            backgroundImage:
                                                NetworkImage(profileImage),
                                            backgroundColor:
                                                Colors.yellow.shade100,
                                            onBackgroundImageError: (_, __) {
                                              // Fallback to initials if image fails to load
                                            },
                                            child: null,
                                          )
                                        : CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                Colors.yellow.shade100,
                                            child: Text(
                                              _getInitials(userName),
                                              style: TextStyle(
                                                color: Colors.yellow.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              ...List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex <
                                                          (review['rating'] ??
                                                              0)
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 14,
                                                  color: Colors.amber.shade600,
                                                );
                                              }),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatDate(
                                                    review['created_at'] ?? ''),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  review['review'] ?? 'No comment provided',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                                if (review['reply'] != null &&
                                    review['reply'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.reply,
                                              size: 14,
                                              color: Colors.yellow.shade700,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Your Reply",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.yellow.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          review['reply'].toString(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
