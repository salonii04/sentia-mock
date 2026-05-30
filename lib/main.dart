import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/message.dart';
import 'models/conversation_mood.dart';
import 'models/planted_flower.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/profile_screen.dart';
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

class SentiaApp extends StatelessWidget {
  const SentiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentia AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SentiaShell(),
    );
  }
}

class SentiaShell extends StatefulWidget {
  const SentiaShell({super.key});

  @override
  State<SentiaShell> createState() => _SentiaShellState();
}

class _SentiaShellState extends State<SentiaShell> {
  // ── Navigation ────────────────────────────────────────────────────────────
  int _currentTab = 1; // 0=Garden, 1=Home, 2=Profile

  // ── Seeds & shop ──────────────────────────────────────────────────────────
  int _currentSeeds = 50;
  List<String> _boughtFlowers = [];

  // ── Planting ──────────────────────────────────────────────────────────────
  String? _selectedFlowerToPlant;
  List<PlantedFlower> _plantedFlowersList = [];

  // ── Conversation mood → drives Garden overlay ─────────────────────────────
  /// Starts neutral; updated by HomeScreen when a branch is chosen.
  ConversationMood _conversationMood = ConversationMood.neutral;

  // ── Chat messages ─────────────────────────────────────────────────────────
  /// Greeting is always the seed for every fresh session.
  List<Message> _chatMessages = [
    Message(text: 'Hi marionette, how are you?', isUser: false),
  ];

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onConversationMoodChanged(ConversationMood mood) {
    setState(() => _conversationMood = mood);
  }

  void _onMessagesChanged(List<Message> messages) {
    setState(() => _chatMessages = messages);
  }

  void _buyFlower(String flower, int cost) {
    if (_currentSeeds < cost) return;
    Navigator.of(context).pop();
    setState(() {
      _currentSeeds -= cost;
      if (!_boughtFlowers.contains(flower)) {
        _boughtFlowers = List.from(_boughtFlowers)..add(flower);
      }
      _selectedFlowerToPlant = flower;
    });
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
          boughtFlowers: _boughtFlowers,
          plantedFlowers: _plantedFlowersList,
          selectedFlowerToPlant: _selectedFlowerToPlant,
          conversationMood: _conversationMood,
          onBuy: _buyFlower,
          onPlantFlower: _onPlantFlower,
          onCancelPlanting: _onCancelPlanting,
        );
      case 2:
        // Pass the current conversation mood so the diary entry reflects
        // whichever track the user engaged with (or defaults to sad).
        return ProfileScreen(conversationMood: _conversationMood);
      case 1:
      default:
        return HomeScreen(
          currentSeeds: _currentSeeds,
          messages: _chatMessages,
          onMessagesChanged: _onMessagesChanged,
          onConversationMoodChanged: _onConversationMoodChanged,
        );
    }
  }
}
