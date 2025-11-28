import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'chat_screen.dart';
import 'result_display_screen.dart';
import 'information_house_screen.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // 浅灰背景，适合 Web
      ),
      // 👇 入口改为 WelcomeScreen (第一步)
      home: const WelcomeScreen(),
    );
  }
}

// ========== 1. WELCOME PAGE (兔子动画) ==========
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

    // Start the animation
    _controller.forward();

    // After 2 seconds, go to loading page
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoadingScreen(), // 去 Loading 页
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
                // Animated Rabbit Image
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
                            // ⚠️ 注意：如果没有 assets/rabbit.png，它会显示备用的图标
                            child: Image.asset(
                              'assets/rabbit.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.pets, // 备用兔子图标
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

                // Welcome Text with fade animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'EcoRabbit',
                            style: TextStyle(
                              fontSize: isDesktop ? 56 : 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI-Driven Smart Living Assistant',
                            style: TextStyle(
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

// ========== 2. LOADING PAGE (转圈圈) ==========
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // After 3 seconds, go to main dashboard
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainDashboardScaffold(), // 去主页
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rabbit Image (Static here)
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
                        child: Icon(
                          Icons.pets,
                          size: isDesktop ? 40 : 30,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Loading Text
              Text(
                'Preparing Your EcoRabbit Experience',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Animated Circular Progress Indicator
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.green[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    strokeWidth: 6,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Loading Message
              Text(
                'Analyzing transit data and housing options...',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: const Color(0xFF388E3C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== 3. MAIN DASHBOARD (原本的主框架) ==========
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
    // 获取屏幕宽度
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800; // 如果宽度大于 800，就认为是电脑/iPad横屏

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
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Icon(Icons.eco, color: Colors.teal, size: 40), // Logo
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

          // --- 垂直分割线 (仅 Web) ---
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          // --- 主要内容区域 ---
          Expanded(
            child: Center(
              // 限制最大宽度，防止内容在宽屏上被拉得太长
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
          ? null // 如果是电脑，就不显示底部栏
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