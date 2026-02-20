import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AstrologerChatPage extends StatefulWidget {
  final String roomId;
  final String myUserId;
  final String receiverId;
  final String receiverName;
  final String? authToken;
  final String? receiverProfileImage;

  const AstrologerChatPage({
    super.key,
    required this.roomId,
    required this.myUserId,
    required this.receiverId,
    required this.receiverName,
    this.authToken,
    this.receiverProfileImage,
  });

  @override
  State<AstrologerChatPage> createState() => _AstrologerChatPageState();
}

class _AstrologerChatPageState extends State<AstrologerChatPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final FastApiServices _api = FastApiServices();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocket? _socket;
  bool _isConnected = false;
  bool _isLoading = true;
  bool _manuallyClosed = false;
  bool _greetingSent = false; // Flag to ensure greeting is sent only once

  // Timer (10 minutes)
  static const int _totalSessionSeconds = 10 * 60;
  int _secondsLeft = _totalSessionSeconds;
  Timer? _sessionTimer;
  bool _timerStarted = false;

  final List<Map<String, dynamic>> _messages = [];

  late String _roomId;
  late String _myUserId;
  late String _token;
  late String _myUserIdFromPrefs;

  // Pagination state
  int _historyPage = 1;
  bool _hasMoreHistory = true;
  bool _loadingHistory = false;
  static const int _pageSize = 50;

  // Customer profile image
  String? _customerProfileImage;

  // UI States
  bool _isCustomerTyping = false;
  Timer? _typingTimer;

  // Animation controllers
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // Contact detection
  Timer? _warningDebounceTimer;

  // Enhanced color scheme
  static const Color primaryYellow = Color(0xFFFFC31F);
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color primaryLight = Color(0xFFF8F9FA);
  static const Color messageBubbleMine = Color(0xFFFFC31F);
  static const Color messageBubbleOther = Colors.white;
  static const Color shadowColor = Color(0x1A000000);
  static const Color appBarGradientStart = Color(0xFF2C3E50);
  static const Color appBarGradientEnd = Color(0xFF1A1A1A);

  // Contact detection constants
  static const List<String> _blockedKeywords = [
    'whatsapp',
    'wa.me',
    'telegram',
    'instagram',
    'fb.com',
    'facebook',
    't.me',
    'telegram.me',
    'signal',
    'wechat',
    'snapchat',
    'line.me',
    'viber',
    'kik',
    'skype',
    'onlyfans',
    'patreon',
    'cashapp',
    'paypal.me',
    'gpay',
    'phonepe',
    'paytm',
    'amazon pay',
    'google pay',
    'whats app',
    'wa me',
    'tele gram',
    'insta',
    'fb',
    'yt',
    'youtube.com',
    'youtu.be',
    'whatsapp.com',
    'wa.link',
    'call me',
    'text me',
    'contact me',
    'my number',
    'reach me',
    'ping me',
    'dm me'
  ];

  static const List<String> _platformPatterns = [
    r'whatsapp\.com',
    r'wa\.me',
    r'telegram\.(me|org)',
    r't\.me',
    r'instagram\.com',
    r'fb\.com',
    r'facebook\.com',
    r'signal\.org',
    r'line\.me',
    r'viber\.com',
    r'kik\.me',
    r'skype\.com',
    r'youtube\.com',
    r'youtu\.be',
    r'wa\.link',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();

    // Initialize typing animation
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _typingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _typingAnimationController, curve: Curves.easeInOut),
    );
    _typingAnimationController.repeat(reverse: true);

    // Add listener for real-time contact detection
    _controller.addListener(_onTextChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
              _scrollController.position.minScrollExtent + 100 &&
          !_loadingHistory &&
          _hasMoreHistory) {
        _loadOlderMessages();
      }
    });
  }

  // Get greeting message based on time of day
  String _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "Good morning!";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon!";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening!";
    } else {
      return "Hello!";
    }
  }

  // Send automatic greeting when chat starts
  void _sendAutomaticGreeting() {
    if (_greetingSent || !_isConnected || _socket == null) return;

    final greeting = _getTimeBasedGreeting();
    final message = "$greeting How can I help you today?";

    // Add to local messages
    setState(() {
      _messages.add({
        'sender_id': _myUserIdFromPrefs,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
      _greetingSent = true;
    });

    // Send via WebSocket
    _socket!.add(jsonEncode({'content': message}));

    // Scroll to bottom to show the greeting
    _scrollToBottom(force: true);
  }

  // Contact Detection Methods
  bool _containsPersonalContact(String message) {
    if (message.isEmpty) return false;

    final lowerMsg = message.toLowerCase();

    // 1. Check for blocked keywords
    for (final keyword in _blockedKeywords) {
      if (lowerMsg.contains(keyword)) {
        debugPrint("🚫 Blocked keyword found: $keyword");
        return true;
      }
    }

    // 2. Check for phone numbers (multiple formats)
    final phonePatterns = [
      r'\b[6-9]\d{9}\b',
      r'(\+91|0091)[6-9]\d{9}\b',
      r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b',
      r'\+\d{1,3}[-.\s]?\d{4,14}\b',
      r'\b\d{10,15}\b',
      r'\b\d{5}[-\s]?\d{5}\b',
      r'\b\d{3}\s?\d{3}\s?\d{4}\b',
    ];

    for (final pattern in phonePatterns) {
      final regex = RegExp(pattern);
      if (regex.hasMatch(message)) {
        debugPrint("📞 Phone number pattern detected");
        return true;
      }
    }

    // 3. Check for email addresses
    final emailPattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b';
    final emailRegex = RegExp(emailPattern);
    if (emailRegex.hasMatch(message)) {
      debugPrint("📧 Email address detected");
      return true;
    }

    // 4. Check for social media/platform URLs
    for (final pattern in _platformPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(message)) {
        debugPrint("🌐 Social media URL detected");
        return true;
      }
    }

    return false;
  }

  List<String> _getDetectedPatterns(String message) {
    final patterns = <String>[];
    final lowerMsg = message.toLowerCase();

    for (final keyword in _blockedKeywords) {
      if (lowerMsg.contains(keyword)) {
        patterns.add('keyword_$keyword');
      }
    }

    if (RegExp(r'\b[6-9]\d{9}\b').hasMatch(message)) {
      patterns.add('phone_indian');
    }

    if (RegExp(r'\+\d{1,3}[-.\s]?\d{4,14}\b').hasMatch(message)) {
      patterns.add('phone_international');
    }

    if (RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(message)) {
      patterns.add('email');
    }

    for (final pattern in _platformPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(message)) {
        patterns.add('social_media');
        break;
      }
    }

    return patterns;
  }

  void _logSuspiciousMessage(String message) {
    final logData = {
      'astrologer_id': _myUserIdFromPrefs,
      'customer_id': widget.receiverId,
      'room_id': _roomId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'detected_patterns': _getDetectedPatterns(message),
    };
    debugPrint("📝 Suspicious message logged: $logData");
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isNotEmpty && _containsPersonalContact(text)) {
      _warningDebounceTimer?.cancel();
      _warningDebounceTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted && _containsPersonalContact(_controller.text)) {
          _showTypingWarning();
        }
      });
    }
  }

  void _showTypingWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sharing personal contact information is not allowed',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showContactWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Warning!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sharing personal contact information is not allowed:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('Phone numbers'),
              _buildBulletPoint('Email addresses'),
              _buildBulletPoint('Social media handles'),
              _buildBulletPoint('WhatsApp / Telegram links'),
              _buildBulletPoint('Payment app details'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'For safety reasons, all conversations are monitored. '
                  'Please keep all communication within the app.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: primaryDark,
              ),
              child: const Text('I Understand'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _fetchCustomerProfile() async {
    try {
      if (widget.receiverProfileImage != null) {
        setState(() {
          _customerProfileImage = _getFullImageUrl(widget.receiverProfileImage);
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching customer profile: $e");
    }
  }

  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;

    if (imagePath.startsWith('http')) return imagePath;

    if (imagePath.startsWith('file://')) {
      final fileName = imagePath.split('/').last;
      return 'https://fastapi.jyotishionline.com/static/uploads/$fileName';
    }

    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      return 'https://fastapi.jyotishionline.com${imagePath.startsWith('/') ? imagePath : '/$imagePath'}';
    }

    return imagePath;
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _roomId = widget.roomId.trim();
    _myUserId = widget.myUserId.trim();
    _token = widget.authToken ?? prefs.getString('access_token') ?? '';
    _myUserIdFromPrefs = prefs.getString('user_id') ?? '';

    debugPrint("🧠 MY USER ID (ASTRO): $_myUserIdFromPrefs");

    await _fetchCustomerProfile();
    await _loadFullChatHistory();

    if (!mounted) return;

    setState(() => _isLoading = false);
    _scrollToBottom(force: true);
    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // HISTORY - FULL LOAD WITH PAGINATION
  // ---------------------------------------------------------------------------

  Future<void> _loadFullChatHistory() async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      try {
        final resp = await _api.getChatHistoryForAstrologerSelf(
          otherUserId: widget.receiverId,
          page: page,
          size: _pageSize,
        );

        final items = (resp['messages'] as List? ?? []);

        if (items.isEmpty) {
          hasMore = false;
        } else {
          for (final m in items) {
            all.add({
              'sender_id': m['sender_user_id']?.toString(),
              'message': m['content']?.toString() ?? '',
              'created_at': m['created_at'],
            });
          }
          page++;
        }
      } catch (e) {
        debugPrint('❌ History error: $e');
        hasMore = false;
      }
    }

    _historyPage = page - 1;
    setState(() {
      _messages.clear();
      _messages.addAll(all);
    });
  }

  Future<void> _loadOlderMessages() async {
    if (_loadingHistory || !_hasMoreHistory) return;
    _loadingHistory = true;

    try {
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: widget.receiverId,
        page: _historyPage + 1,
        size: _pageSize,
      );

      final items = (resp['messages'] as List? ?? []);

      if (items.isEmpty) {
        _hasMoreHistory = false;
      } else {
        _historyPage++;
        final oldScrollPosition = _scrollController.position.pixels;
        final oldItemCount = _messages.length;

        setState(() {
          _messages.insertAll(
            0,
            items.map((m) => {
                  'sender_id': m['sender_user_id']?.toString(),
                  'message': m['content']?.toString() ?? '',
                  'created_at': m['created_at'],
                }),
          );
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final newItemCount = _messages.length;
            final itemsAdded = newItemCount - oldItemCount;
            final newScrollPosition = oldScrollPosition +
                (_scrollController.position.maxScrollExtent *
                    (itemsAdded / newItemCount));
            _scrollController.jumpTo(newScrollPosition);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Older messages error: $e');
    }
    _loadingHistory = false;
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_socket != null || _manuallyClosed) return;

    final uri = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/$_roomId',
      queryParameters: {'token': _token},
    );

    try {
      _socket = await WebSocket.connect(uri.toString());
      _socket!.pingInterval = const Duration(seconds: 20);

      setState(() => _isConnected = true);

      _socket!.listen(
        _onMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );

      // Start timer immediately when connected
      _startSessionTimer();

      // Send automatic greeting after connection is established
      // Add a small delay to ensure the connection is fully ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _isConnected) {
          _sendAutomaticGreeting();
        }
      });
    } catch (e) {
      debugPrint('❌ WebSocket connection error: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _stopSessionTimer();
    _socket = null;
    setState(() => _isConnected = false);
  }

  void _onMessage(dynamic data) async {
    try {
      final raw = data is String ? data : utf8.decode(data);
      final parsed = jsonDecode(raw);

      // Handle typing indicator
      if (parsed['type'] == 'connectivity') {
        if (parsed['status'] == 'typing') {
          _handleTypingIndicator(parsed['is_typing'] ?? false);
        }
        return;
      }

      // Normal message
      if (parsed['type'] != 'message') return;

      final msg = parsed['message'];
      if (msg is! Map) return;

      final senderId = msg['sender_user_id']?.toString() ?? '';
      if (senderId == _myUserIdFromPrefs) return;

      setState(() {
        _messages.add({
          'sender_id': senderId,
          'message': msg['content']?.toString() ?? '',
          'created_at': msg['created_at'],
        });
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ WS error: $e');
    }
  }

  void _handleTypingIndicator(bool isTyping) {
    setState(() {
      _isCustomerTyping = isTyping;
    });

    if (isTyping) {
      _typingTimer?.cancel();
    } else {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isCustomerTyping = false);
        }
      });
    }
  }

  void _sendTypingIndicator(bool isTyping) {
    if (_socket != null && _isConnected) {
      _socket!.add(jsonEncode({
        "type": "connectivity",
        "status": "typing",
        "is_typing": isTyping,
        "user_id": _myUserIdFromPrefs,
        "room_id": _roomId,
      }));
    }
  }

  void _startSessionTimer() {
    if (_timerStarted) return;
    _timerStarted = true;

    _sessionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_secondsLeft <= 0) {
          _showTimeUpDialog();
          _stopSessionTimer();
          return;
        }
        setState(() => _secondsLeft--);
      },
    );
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Icon(Icons.timer_off, color: primaryYellow, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Chat Session Ended',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'Your 10-minute chat session has ended.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  foregroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('OK',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _timerStarted = false;
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected || _socket == null) return;

    // Check for personal contact info
    if (_containsPersonalContact(text)) {
      _logSuspiciousMessage(text);
      _showContactWarningDialog();
      return;
    }

    setState(() {
      _messages.add({
        'sender_id': _myUserIdFromPrefs,
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _socket!.add(jsonEncode({'content': text}));

    _controller.clear();
    _scrollToBottom(force: true);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (force) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      return DateFormat('h:mm a').format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTextChanged);
    _warningDebounceTimer?.cancel();
    _typingAnimationController.dispose();
    _typingTimer?.cancel();

    _stopSessionTimer();
    _socket?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryLight,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryYellow))
          : Column(
              children: [
                _buildConnectionStatus(),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: _buildMessageList(),
                  ),
                ),
                if (_isCustomerTyping) _buildTypingIndicator(),
                _buildInputArea(),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    final progress = _secondsLeft / _totalSessionSeconds;

    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appBarGradientStart, appBarGradientEnd],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _buildCustomerAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildTimerWidget(progress, minutes, seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar() {
    final hasValidImage =
        _customerProfileImage != null && _customerProfileImage!.isNotEmpty;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryYellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: hasValidImage
            ? CachedNetworkImage(
                imageUrl: _customerProfileImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildAvatarPlaceholder(),
                errorWidget: (context, url, error) {
                  debugPrint("Error loading profile image: $error");
                  return _buildAvatarPlaceholder();
                },
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    String? firstLetter;
    if (widget.receiverName.isNotEmpty) {
      firstLetter = widget.receiverName[0].toUpperCase();
    }

    return Container(
      color: Colors.grey[300],
      child: Center(
        child: firstLetter != null
            ? Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const Icon(
                Icons.person,
                color: Colors.grey,
                size: 30,
              ),
      ),
    );
  }

  Widget _buildTimerWidget(double progress, String minutes, String seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.3 ? Colors.red : primaryYellow,
                  ),
                  strokeWidth: 3,
                ),
              ),
              Icon(
                Icons.timer,
                color: progress < 0.3 ? Colors.red : primaryYellow,
                size: 18,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              color: progress < 0.3 ? Colors.red : primaryYellow,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    if (_isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.red[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          const Text(
            'Connecting... Please wait',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/chat_bg_pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (_, i) {
          final m = _messages[i];
          final isMine = m['sender_id'] == _myUserIdFromPrefs;
          final showAvatar = !isMine &&
              (i == 0 || _messages[i - 1]['sender_id'] != m['sender_id']);
          return _buildEnhancedBubble(m, isMine, showAvatar);
        },
      ),
    );
  }

  Widget _buildEnhancedBubble(
      Map<String, dynamic> m, bool isMine, bool showAvatar) {
    final messageTime = DateTime.parse(m['created_at']);
    final timeString = DateFormat('h:mm a').format(messageTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine && showAvatar)
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryYellow, width: 1.5),
              ),
              child: ClipOval(
                child: _customerProfileImage != null
                    ? CachedNetworkImage(
                        imageUrl: _customerProfileImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person,
                              color: Colors.grey, size: 16),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person,
                              color: Colors.grey, size: 16),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person,
                            color: Colors.grey, size: 16),
                      ),
              ),
            ),
          if (!isMine && !showAvatar) const SizedBox(width: 38),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMine ? messageBubbleMine : messageBubbleOther,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: !isMine && showAvatar
                      ? Radius.zero
                      : const Radius.circular(20),
                  bottomRight: isMine && showAvatar
                      ? Radius.zero
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m['message'] ?? "",
                    style: TextStyle(
                      fontSize: 15,
                      color: isMine ? Colors.black : primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.black54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryYellow, width: 1),
            ),
            child: ClipOval(
              child: _customerProfileImage != null
                  ? CachedNetworkImage(
                      imageUrl: _customerProfileImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person,
                            color: Colors.grey, size: 16),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person,
                            color: Colors.grey, size: 16),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person,
                          color: Colors.grey, size: 16),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _typingAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _typingAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _typingAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                onChanged: (text) {
                  _sendTypingIndicator(text.isNotEmpty);
                },
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined,
                              color: primaryYellow),
                          onPressed: () {
                            // Emoji picker can be added here
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? primaryYellow : Colors.grey[400],
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: _isConnected ? primaryDark : Colors.white,
              ),
              onPressed: _isConnected ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }
}
