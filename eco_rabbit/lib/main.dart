import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 你的其他页面 Imports
import 'home_screen.dart';
import 'map_screen.dart';
import 'chat_screen.dart';
import 'result_display_screen.dart';
import 'information_house_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EcoRabbitWeb());
}

class EcoRabbitWeb extends StatelessWidget {
  const EcoRabbitWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRabbit Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ========== 1. WELCOME PAGE (保持不变) ==========
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoadingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: isDesktop ? 200 : 150,
                          height: isDesktop ? 200 : 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/rabbit.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.pets,
                                    size: isDesktop ? 60 : 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: isDesktop ? 60 : 40),

                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'EcoRabbit',
                            style: GoogleFonts.caveat(
                              fontSize: isDesktop ? 56 : 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI-Driven Smart Living Assistant',
                            style: GoogleFonts.caveat(
                              fontSize: isDesktop ? 20 : 16,
                              color: const Color(0xFF388E3C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== 2. LOADING PAGE (保持不变) ==========
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _carrotCount = 0;

  @override
  void initState() {
    super.initState();
    _showCarrotsSequentially();
  }

  void _showCarrotsSequentially() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() { _carrotCount = 1; });
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() { _carrotCount = 2; });
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() { _carrotCount = 3; });
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainDashboardScaffold(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isDesktop ? 120 : 80,
                height: isDesktop ? 120 : 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/rabbit.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.pets, size: isDesktop ? 40 : 30, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Preparing Your EcoRabbit Experience',
                style: GoogleFonts.caveat(
                  fontSize: isDesktop ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: isDesktop ? 200 : 150,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.green[100],
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Loading', style: TextStyle(fontSize: 16, color: Color(0xFF388E3C))),
                  Text('.', style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF388E3C), fontWeight: FontWeight.bold)),
                  Text('.', style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF388E3C), fontWeight: FontWeight.bold)),
                  Text('.', style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF388E3C), fontWeight: FontWeight.bold)),
                  if (_carrotCount >= 1) Text(' 🥕', style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF388E3C))),
                  if (_carrotCount >= 2) Text('🥕', style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF388E3C))),
                  if (_carrotCount >= 3) Text('🥕', style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF388E3C))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== 3. MAIN DASHBOARD (已修改 Leading Logo) ==========
class MainDashboardScaffold extends StatefulWidget {
  const MainDashboardScaffold({super.key});

  @override
  State<MainDashboardScaffold> createState() => _MainDashboardScaffoldState();
}

class _MainDashboardScaffoldState extends State<MainDashboardScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MapScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return Scaffold(
      body: Row(
        children: [
          // --- Web 版专用：左侧侧边栏 ---
          if (isDesktop)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              // 🔥🔥🔥 这里改了！换成了兔子图片 🔥🔥🔥
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/rabbit.png', // ✅ 兔子上位！
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 备用方案：如果图片加载失败，显示原来的 Eco Icon
                        return const Icon(Icons.eco, color: Colors.teal, size: 30);
                      },
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: Text('City Layers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.smart_toy_outlined),
                  selectedIcon: Icon(Icons.smart_toy),
                  label: Text('AI Agent'),
                ),
              ],
            ),

          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000), 
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),

      // --- 手机版专用：底部导航栏 ---
      bottomNavigationBar: isDesktop
          ? null 
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
                NavigationDestination(icon: Icon(Icons.smart_toy_outlined), label: 'AI'),
              ],
            ),
    );
  }
}