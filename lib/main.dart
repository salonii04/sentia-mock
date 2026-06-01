import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/conversation_mood.dart';
import 'models/message.dart';
import 'models/planted_flower.dart';
import 'screens/garden_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/seed_service.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SentiaApp());
}

class SentiaApp extends StatefulWidget {
  const SentiaApp({super.key});

  @override
  State<SentiaApp> createState() => _SentiaAppState();
}

class _SentiaAppState extends State<SentiaApp> {
  final _authService = AuthService();
  bool _isSessionReady = false;
  bool _isLoggedIn = false;
  String _username = 'Marionette';

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final loggedIn = await _authService.isLoggedIn();
    final username = await _authService.getUsername();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = loggedIn;
      _username = username;
      _isSessionReady = true;
    });
  }

  Future<void> _onAuthSuccess() async {
    final username = await _authService.getUsername();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
  }

  Future<void> _onLogout() async {
    await _authService.logout();
    if (!mounted) return;
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentia AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_isSessionReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) {
      return SentiaShell(
        username: _username,
        onLogout: _onLogout,
      );
    }

    return LoginScreen(onLoginSuccess: _onAuthSuccess);
  }
}

class SentiaShell extends StatefulWidget {
  final String username;
  final Future<void> Function() onLogout;

  const SentiaShell({
    super.key,
    required this.username,
    required this.onLogout,
  });

  @override
  State<SentiaShell> createState() => _SentiaShellState();
}

class _SentiaShellState extends State<SentiaShell> {
  final _seedService = SeedService();

  int _currentTab = 1; // 0=Garden, 1=Home, 2=Profile
  int _currentSeeds = SeedService.initialSeeds;

  String? _selectedFlowerToPlant;
  List<PlantedFlower> _plantedFlowersList = [];

  ConversationMood _conversationMood = ConversationMood.neutral;

  List<Message> _chatMessages = [
    Message(text: 'Hi marionette, how are you?', isUser: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadSeeds();
  }

  Future<void> _loadSeeds() async {
    final persistedSeeds = await _seedService.getCurrentSeeds();
    if (!mounted) return;
    setState(() => _currentSeeds = persistedSeeds);
  }

  void _onConversationMoodChanged(ConversationMood mood) {
    setState(() => _conversationMood = mood);
  }

  void _onMessagesChanged(List<Message> messages) {
    setState(() => _chatMessages = messages);
  }

  void _buyFlower(String flower, int cost) {
    if (_currentSeeds < cost) return;
    Navigator.of(context).pop();

    final updatedSeeds = _currentSeeds - cost;
    setState(() {
      _currentSeeds = updatedSeeds;
      // selectedFlowerToPlant activates planting mode for this flower type.
      // A unique ID is generated at tap time in garden_screen.dart so the
      // same type can be planted multiple times without state collision.
      _selectedFlowerToPlant = flower;
    });
    _seedService.setCurrentSeeds(updatedSeeds);
  }

  void _onPlantFlower(PlantedFlower flower) {
    setState(() {
      _plantedFlowersList = List.from(_plantedFlowersList)..add(flower);
      _selectedFlowerToPlant = null;
    });
  }

  void _onCancelPlanting() {
    setState(() => _selectedFlowerToPlant = null);
  }

  void _onTabTap(int index) {
    setState(() => _currentTab = index);
  }

  SeedMood _rewardMoodForConversation(ConversationMood mood) {
    switch (mood) {
      case ConversationMood.sadExamTrack:
        return SeedMood.sad;
      case ConversationMood.happyProposalTrack:
        return SeedMood.happy;
      case ConversationMood.neutral:
        return SeedMood.reflective;
    }
  }

  Future<RewardMessageData> _onConversationCompleted(
      ConversationMood mood) async {
    final previousSeeds = _currentSeeds;
    final rewardResult = await _seedService.grantDailyReward(
      mood: _rewardMoodForConversation(mood),
    );
    if (mounted) {
      setState(() => _currentSeeds = rewardResult.currentSeeds);
    }

    if (!rewardResult.awarded) {
      return const RewardMessageData.locked();
    }

    return RewardMessageData.awarded(
      grantedSeeds: rewardResult.grantedAmount,
      previousSeeds: previousSeeds,
      updatedSeeds: rewardResult.currentSeeds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey(_currentTab),
              child: _buildCurrentScreen(),
            ),
          ),
          SentiaBottomNav(
            currentIndex: _currentTab,
            onTap: _onTabTap,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentTab) {
      case 0:
        return GardenScreen(
          currentSeeds: _currentSeeds,
          boughtFlowers: const [],
          plantedFlowers: _plantedFlowersList,
          selectedFlowerToPlant: _selectedFlowerToPlant,
          conversationMood: _conversationMood,
          onBuy: _buyFlower,
          onPlantFlower: _onPlantFlower,
          onCancelPlanting: _onCancelPlanting,
        );
      case 2:
        return ProfileScreen(
          conversationMood: _conversationMood,
          currentSeeds: _currentSeeds,
          username: widget.username,
          isLoggedIn: true,
          onLogout: widget.onLogout,
        );
      case 1:
      default:
        return HomeScreen(
          currentSeeds: _currentSeeds,
          messages: _chatMessages,
          onMessagesChanged: _onMessagesChanged,
          onConversationMoodChanged: _onConversationMoodChanged,
          onConversationCompleted: _onConversationCompleted,
        );
    }
  }
}
