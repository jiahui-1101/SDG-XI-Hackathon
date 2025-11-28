import 'package:flutter/material.dart';
import 'home_screen.dart';
//import 'map_screen.dart';
//import 'chat_screen.dart';

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
      home: const MainDashboardScaffold(),
    );
  }
}

class MainDashboardScaffold extends StatefulWidget {
  const MainDashboardScaffold({super.key});

  @override
  State<MainDashboardScaffold> createState() => _MainDashboardScaffoldState();
}

class _MainDashboardScaffoldState extends State<MainDashboardScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
   // const MapScreen(),
   // const ChatScreen(),
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