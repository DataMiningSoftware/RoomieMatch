import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/db_service.dart';
import '../app_theme.dart';
import '../widgets/app_bottom_nav.dart';

import '../filter_page.dart';
import '../info_page.dart';
import 'home.dart';
import 'chat.dart';
import 'settings/settings.dart';
import 'notifications.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _displayed = [];

  // Filter state
  int _selectedDistance = 99;
  int _selectedGenderIndex = 2;
  double _minAge = 18;
  double _maxAge = 60;
  double _minBudget = 250;
  double _maxBudget = 3000;

  // Drag / animation state
  Offset _drag = Offset.zero;
  late AnimationController _controller;
  Animation<Offset>? _animation;

  bool _isLoading = true;

  static const double _swipeThreshold = 110;

  static const List<String> _malePhoto = [
    'assets/profile/2.jpg',
    'assets/profile/4.png',
    'assets/profile/7.jpg',
    'assets/profile/8.png',
    'assets/profile/10.png'
  ];
  static const List<String> _femalePhoto = [
    'assets/profile/1.jpg',
    'assets/profile/3.png',
    'assets/profile/4.png',
    'assets/profile/5.png',
    'assets/profile/6.png',
    'assets/profile/9.png',
    'assets/profile/11.jpeg'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    getMatches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getMatches() async {
    final response = await DBService.getAllMatches();

    if (response["status"] == "OK") {
      final matches = response['matches'] as List;
      int male = 0, female = 0;

      for (final m in matches) {
        final match = Map<String, dynamic>.from(m);
        final gender = match['gender'] ?? "F";
        final photo = gender == "M"
            ? _malePhoto[male++ % _malePhoto.length]
            : _femalePhoto[female++ % _femalePhoto.length];

        _profiles.add({
          ...match,
          'image': photo,
          'matched': 0,
        });
      }

      _profiles.sort((a, b) => (b['match_score'] as num).compareTo(a['match_score'] as num));
      _displayed = List.from(_profiles);
      _applyFiltersInPlace(_displayed);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _applyFiltersInPlace(List<Map<String, dynamic>> list) {
    list.removeWhere((p) {
      if (_selectedDistance != 99 &&
          _selectedDistance < int.parse(p["distance"].toString())) {
        return true;
      }
      if (_selectedGenderIndex != 2) {
        if (_selectedGenderIndex == 0 && p["gender"] == "F") return true;
        if (_selectedGenderIndex == 1 && p["gender"] == "M") return true;
      }
      final age = int.parse(p["age"].toString());
      if (age < _minAge || age > _maxAge) return true;
      final budget = int.parse(p["budget"].toString());
      if (budget < _minBudget || budget > _maxBudget) return true;
      return false;
    });
  }

  void filterMatches(int distance, int genderIndex, double minAge, double maxAge, double minBudget, double maxBudget) {
    setState(() {
      _selectedDistance = distance;
      _selectedGenderIndex = genderIndex;
      _minAge = minAge;
      _maxAge = maxAge;
      _minBudget = minBudget;
      _maxBudget = maxBudget;

      _displayed = List.from(_profiles);
      _applyFiltersInPlace(_displayed);
      _drag = Offset.zero;
    });
  }

  double get _rotation {
    final width = MediaQuery.of(context).size.width;
    return _drag.dx / width * 0.35;
  }

  double get _likeOpacity {
    final v = _drag.dx / _swipeThreshold;
    return v.clamp(0.0, 1.0);
  }

  double get _nopeOpacity {
    final v = -_drag.dx / _swipeThreshold;
    return v.clamp(0.0, 1.0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _drag += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dx = _drag.dx;

    if (dx > _swipeThreshold || (dx > 0 && velocity > 900)) {
      _animateOffScreen(swipeRight: true);
    } else if (dx < -_swipeThreshold || (dx < 0 && velocity < -900)) {
      _animateOffScreen(swipeRight: false);
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    _runAnimation(Offset.zero, onDone: () => setState(() {}));
  }

  void _animateOffScreen({required bool swipeRight}) {
    final width = MediaQuery.of(context).size.width;
    final target = Offset(swipeRight ? width * 1.4 : -width * 1.4, _drag.dy);

    _runAnimation(target, onDone: () {
      final card = _displayed.isNotEmpty ? _displayed.first : null;
      if (card != null) {
        final profile = _profiles.firstWhere((p) => p['user_id'] == card['user_id'], orElse: () => card);
        profile['matched'] = 1;
        DBService.updateMatch(card['user_id'], swipeRight ? 1 : 0);
      }
      setState(() {
        if (_displayed.isNotEmpty) _displayed.removeAt(0);
        _drag = Offset.zero;
      });
    });
  }

  void _runAnimation(Offset target, {VoidCallback? onDone}) {
    final start = _drag;
    _controller.stop();
    _controller.reset();
    _animation = Tween<Offset>(begin: start, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.removeListener(_onAnimTick);
    _controller.addListener(_onAnimTick);

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.removeStatusListener(statusListener);
        if (onDone != null) onDone();
      }
    }

    _controller.addStatusListener(statusListener);
    _controller.forward();
  }

  void _onAnimTick() {
    if (_animation != null && mounted) {
      setState(() => _drag = _animation!.value);
    }
  }

  void _swipeButton(bool toRight) {
    if (_displayed.isEmpty) return;
    _animateOffScreen(swipeRight: toRight);
  }

  void _openFilterOverlay() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 8,
              color: Colors.white,
              child: FilterWidget(
                initialDistance: _selectedDistance,
                initialGenderIndex: _selectedGenderIndex,
                initialMinAge: _minAge.round(),
                initialMaxAge: _maxAge.round(),
                initialMinBudget: _minBudget.round(),
                initialMaxBudget: _maxBudget.round(),
                onApply: filterMatches,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) return;
    Widget page = const HomePage();
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const ChatPage();
        break;
      case 3:
        page = const SettingsPage();
        break;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = _displayed.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          children: const [
            Text('RoomieMatch', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: _openFilterOverlay,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(child: hasCards ? _buildCardStack() : _buildEmptyState()),
                if (hasCards) _buildActionButtons(),
                const SizedBox(height: 8),
              ],
            ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 2, onTap: _onItemTapped),
    );
  }

  Widget _buildCardStack() {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width * 0.88;

    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = math.min(2, _displayed.length - 1); i >= 0; i--)
          Positioned.fill(
            child: Center(
              child: i == 0
                  ? _buildDraggableCard(_displayed[i], cardWidth)
                  : _buildBackCard(_displayed[i], cardWidth, i),
            ),
          ),
      ],
    );
  }

  Widget _buildBackCard(Map<String, dynamic> card, double width, int depth) {
    final scale = 1.0 - (depth * 0.05);
    final dy = depth * 18.0;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Transform.scale(
        scale: scale,
        child: _cardVisual(card, width, opacity: depth == 1 ? 0.9 : 0.7),
      ),
    );
  }

  Widget _buildDraggableCard(Map<String, dynamic> card, double width) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _drag,
        child: Transform.rotate(
          angle: _rotation,
          child: Stack(
            children: [
              _cardVisual(card, width),
              Positioned(
                top: 32,
                left: 20,
                child: _StampLabel('NOPE', AppColors.nope, _nopeOpacity, rotate: -0.15),
              ),
              Positioned(
                top: 32,
                right: 20,
                child: _StampLabel('LIKE', AppColors.like, _likeOpacity, rotate: 0.15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardVisual(Map<String, dynamic> card, double width, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: MediaQuery.of(context).size.height * 0.56,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(card['image'] as String, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: _MatchScoreChip(card['match_score']),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          '${card['first_name']}, ${card['age']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _InfoPill(Icons.location_on, '${card['distance']} km'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card['job'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['bio'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  _InterestsRow(card['interests'] as List? ?? const []),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(icon: Icons.replay, color: AppColors.rewind, size: 46, onTap: () {}),
          _ActionButton(icon: Icons.close, color: AppColors.nope, size: 62, onTap: () => _swipeButton(false)),
          _ActionButton(icon: Icons.star, color: AppColors.superLike, size: 46, onTap: () => _swipeButton(true)),
          _ActionButton(icon: Icons.favorite, color: AppColors.like, size: 62, onTap: () => _swipeButton(true)),
          _ActionButton(icon: Icons.info_outline, color: AppColors.primary, size: 46, onTap: _openInfo),
        ],
      ),
    );
  }

  void _openInfo() {
    if (_displayed.isEmpty) return;
    final card = _displayed.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(
          name: card['first_name'],
          age: card['age'].toString(),
          imagePath: card['image'],
          distance: '${card['distance']} km',
          location: card['location'] ?? 'Sample Location',
          about: card['bio'] ?? '',
          preferences: (card['interests'] as List? ?? const []).cast<String>(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, size: 72, color: AppColors.accentStrong),
          const SizedBox(height: 16),
          const Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'No more profiles match your filters right now.',
            style: TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _displayed = List.from(_profiles);
                _applyFiltersInPlace(_displayed);
                _drag = Offset.zero;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _StampLabel extends StatelessWidget {
  final String text;
  final Color color;
  final double opacity;
  final double rotate;

  const _StampLabel(this.text, this.color, this.opacity, {required this.rotate});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: rotate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchScoreChip extends StatelessWidget {
  final dynamic score;
  const _MatchScoreChip(this.score);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text('${score.toString()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InterestsRow extends StatelessWidget {
  final List interests;
  const _InterestsRow(this.interests);

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: interests
          .take(3)
          .map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  i.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ))
          .toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: color, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
