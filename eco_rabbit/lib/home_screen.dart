import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'models/property_model.dart';
import 'information_house_screen.dart';
import 'result_display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 1500;
  double _monthlySalary = 5000;
  double _vibeValue = 0.5;
  String _selectedChip = "Near MRT";
  bool _hasSearched = false;
  String _workplace = "";
  String _currentLocation = ""; // 新增：当前居住地

  // 添加结果数据
  List<PropertyResult> _allResults = [];
  List<PropertyResult> _displayedResults = [];
  bool _showAllResults = false;

  // 在 _performSearch() 方法中添加弹窗提示
  // 在 _performSearch() 方法中添加弹窗提示
  void _performSearch() {
    if (_workplace.isEmpty || _currentLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both workplace and current location')),
      );
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    // 显示绿色搜索弹窗
    _showSearchingPopup();

    // 直接在当前页面加载和显示结果，不跳转
    _loadAndCalculateResults();
  }

// 绿色搜索弹窗提示
  void _showSearchingPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 2秒后自动关闭并显示结果提示
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
          // 显示结果提示弹窗
          _showResultsReadyPopup();
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 绿色图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // 标题
                Text(
                  "Searching Eco-Homes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                // 描述
                Text(
                  "Finding the best properties for your commute",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // 加载动画
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// 简洁版结果提示弹窗
  void _showResultsReadyPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // 3秒后自动关闭
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 紧凑的图标和箭头
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                    Positioned(
                      bottom: -8,
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 简洁的标题
                Text(
                  "Results Ready!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                // 简洁的描述
                Text(
                  "Scroll down to view results",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Eco Score 算法 (保持不变)
  double _calculateEcoScore(PropertyResult property) {
    double affordabilityScore = _calculateAffordabilityScore(property.price);
    double connectivityScore = _calculateConnectivityScore(
        property.details.distanceToStation, property.details.commuteTime);
    double trafficRiskScore =
        _calculateTrafficRiskScore(property.distanceToWork, property.area);

    return (affordabilityScore * 0.3) +
        (connectivityScore * 0.4) +
        (trafficRiskScore * 0.3);
  }

  double _calculateAffordabilityScore(double rent) {
    double rentToSalaryRatio = rent / _monthlySalary;
    if (rentToSalaryRatio <= 0.2) return 100;
    if (rentToSalaryRatio <= 0.3) return 80;
    if (rentToSalaryRatio <= 0.4) return 60;
    if (rentToSalaryRatio <= 0.5) return 40;
    return 20;
  }

  double _calculateConnectivityScore(int distanceToStation, int commuteTime) {
    double stationScore = 0;
    double commuteScore = 0;

    if (distanceToStation <= 200)
      stationScore = 100;
    else if (distanceToStation <= 500)
      stationScore = 80;
    else if (distanceToStation <= 1000)
      stationScore = 60;
    else if (distanceToStation <= 1500)
      stationScore = 40;
    else
      stationScore = 20;

    if (commuteTime <= 20)
      commuteScore = 100;
    else if (commuteTime <= 35)
      commuteScore = 80;
    else if (commuteTime <= 50)
      commuteScore = 60;
    else if (commuteTime <= 65)
      commuteScore = 40;
    else
      commuteScore = 20;

    return (stationScore * 0.6) + (commuteScore * 0.4);
  }

  double _calculateTrafficRiskScore(double distanceToWork, String area) {
    double distanceScore = 0;
    double areaScore = 0;

    if (distanceToWork <= 5)
      distanceScore = 100;
    else if (distanceToWork <= 10)
      distanceScore = 80;
    else if (distanceToWork <= 15)
      distanceScore = 60;
    else if (distanceToWork <= 20)
      distanceScore = 40;
    else
      distanceScore = 20;

    final lowCongestionAreas = ['Mont Kiara', 'KLCC', 'Bangsar South'];
    final mediumCongestionAreas = ['Petaling Jaya'];
    final highCongestionAreas = ['Cheras', 'Setapak'];

    if (lowCongestionAreas.contains(area)) {
      areaScore = 100;
    } else if (mediumCongestionAreas.contains(area)) {
      areaScore = 70;
    } else if (highCongestionAreas.contains(area)) {
      areaScore = 40;
    } else {
      areaScore = 60;
    }

    return (distanceScore * 0.5) + (areaScore * 0.5);
  }

  void _loadAndCalculateResults() {
    // 模拟数据 - 保持不变
    final mockResults = [
      PropertyResult(
        id: '1',
        name: 'Cheras Green Condo',
        distanceToWork: 8.5,
        area: 'Cheras',
        price: 1300,
        imageUrl:
            "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 2,
          bathrooms: 2,
          size: 850,
          amenities: ['Pool', 'Gym', 'MRT Shuttle'],
          commuteTime: 35,
          distanceToStation: 350,
        ),
        ecoScore: 0,
      ),
      PropertyResult(
        id: '2',
        name: 'Bangsar South Loft',
        distanceToWork: 6.2,
        area: 'Bangsar South',
        price: 1800,
        imageUrl:
            "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 1,
          bathrooms: 1,
          size: 650,
          amenities: ['LRT Connected', 'Garden'],
          commuteTime: 25,
          distanceToStation: 150,
        ),
        ecoScore: 0,
      ),
      PropertyResult(
        id: '3',
        name: 'Setapak Budget Flat',
        distanceToWork: 15.2,
        area: 'Setapak',
        price: 1100,
        imageUrl:
            "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 3,
          bathrooms: 2,
          size: 1100,
          amenities: ['Family Friendly', 'Parking'],
          commuteTime: 55,
          distanceToStation: 1200,
        ),
        ecoScore: 0,
      ),
      PropertyResult(
        id: '4',
        name: 'KLCC Sky View Condo',
        distanceToWork: 3.5,
        area: 'KLCC',
        price: 2000,
        imageUrl:
            "https://images.unsplash.com/photo-1513584684374-8bab748fbf90?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 2,
          bathrooms: 2,
          size: 900,
          amenities: ['City View', 'Concierge'],
          commuteTime: 15,
          distanceToStation: 500,
        ),
        ecoScore: 0,
      ),
      PropertyResult(
        id: '5',
        name: 'Mont Kiara Luxury Suite',
        distanceToWork: 7.8,
        area: 'Mont Kiara',
        price: 2200,
        imageUrl:
            "https://images.unsplash.com/photo-1567767292278-a4f21aa2d36e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 3,
          bathrooms: 2,
          size: 1200,
          amenities: ['Pool', 'Gym', 'Security'],
          commuteTime: 30,
          distanceToStation: 400,
        ),
        ecoScore: 0,
      ),
    ];

    // 计算每个房源的Eco Score
    for (var property in mockResults) {
      property.ecoScore = _calculateEcoScore(property).round();
    }

    // 按Eco Score排序
    mockResults.sort((a, b) => b.ecoScore.compareTo(a.ecoScore));

    setState(() {
      _allResults = mockResults;
      // 确保默认显示前3个结果
      _displayedResults = _allResults.take(3).toList();
      _showAllResults = false; // 重置为显示Top 3
    });
  }

  // 其他方法保持不变...
  void _showAllResultsAction() {
    setState(() {
      _showAllResults = true;
      _displayedResults = _allResults;
    });
  }

  void _showScoreBreakdown(int score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eco Score Breakdown"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreMetric("Affordability (30%)",
                "Based on rent/salary ratio", 0.3 * score),
            _buildScoreMetric("Transport Connectivity (40%)",
                "Distance to public transport", 0.4 * score),
            _buildScoreMetric("Low Traffic Risk (30%)",
                "Congestion zone analysis", 0.3 * score),
            const SizedBox(height: 16),
            Text(
              "Total Score: $score/100",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMetric(String title, String description, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[200],
            color: Colors.teal,
          ),
          Text("${score.toStringAsFixed(1)} points",
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (MediaQuery.of(context).size.width < 800)
              const Icon(Icons.eco, color: Colors.teal),
            const SizedBox(width: 10),
            const Text(
              "EcoRabbit Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: Text(
              "Hi, Miss Rabbit ",
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ClipOval(
            // 🔥 这里的 'assets/rabbit_look.png' 必须存在你的文件夹里
            // 如果没有，它会优雅地降级显示一个 Icon
            child: Image.asset(
              'assets/rabbit_look.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.pets, color: Colors.pink, size: 30),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smart Commute Search",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Find a home that saves your time and the planet.",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 30),

            // --- Search Card ---
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 30,
                        runSpacing: 20,
                        children: [
                          // Workplace input
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.45
                                : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Workplace Location",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  onChanged: (value) => _workplace = value,
                                  decoration: InputDecoration(
                                    hintText: "e.g., KL Sentral, TRX",
                                    prefixIcon: const Icon(
                                      Icons.work_outline,
                                      color: Colors.teal,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Current Staying Location input
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.45
                                : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Current Staying Location",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  onChanged: (value) =>
                                      _currentLocation = value,
                                  decoration: InputDecoration(
                                    hintText:
                                        "e.g., Petaling Jaya, Subang Jaya",
                                    prefixIcon: const Icon(
                                      Icons.home_work_outlined,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Budget slider
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.45
                                : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Monthly Budget",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "RM ${_budget.round()}",
                                      style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _budget,
                                  min: 500,
                                  max: 5000,
                                  divisions: 45,
                                  activeColor: Colors.teal,
                                  onChanged: (v) => setState(() => _budget = v),
                                ),
                              ],
                            ),
                          ),
                          // Monthly Salary slider
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.45
                                : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Monthly Salary",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "RM ${_monthlySalary.round()}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _monthlySalary,
                                  min: 2000,
                                  max: 20000,
                                  divisions: 36,
                                  activeColor: Colors.green,
                                  onChanged: (v) =>
                                      setState(() => _monthlySalary = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    "Preferred Vibe (Feature 2 Filter)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.park, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          value: _vibeValue,
                          onChanged: (v) => setState(() => _vibeValue = v),
                          activeColor: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.local_fire_department,
                          color: Colors.red),
                    ],
                  ),
                  Center(
                    child: Text(
                      _vibeValue < 0.5
                          ? "Currently: Quiet Area"
                          : "Currently: Vibrant Area",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text("Find Eco-Homes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // 改为绿色
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 只在搜索后才显示以下内容
            if (_hasSearched) ...[
              // ---------- Quick Filters ----------
              const SizedBox(height: 40),
              const Text(
                "Quick Filters",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChoiceChip("Near MRT", Icons.directions_subway),
                    _buildChoiceChip("Safe Zone", Icons.security),
                    _buildChoiceChip("Student", Icons.school),
                    _buildChoiceChip("Family", Icons.family_restroom),
                    _buildChoiceChip("Low Carbon", Icons.eco),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------- Results Section ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showAllResults
                        ? "All Results (${_allResults.length})"
                        : "Top 3 Recommendations",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // 在首页的 See All 按钮
                  if (!_showAllResults && _allResults.length > 3)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultDisplayScreen(
                              workplace: _workplace,
                              budget: _budget,
                              monthlySalary: _monthlySalary,
                              properties: _allResults, // 传递所有结果
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "See All",
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 16, color: Colors.teal),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Ranked by Eco Score - Best matches for your commute needs",
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 20),

              // 结果显示
              _displayedResults.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          "No properties found matching your criteria",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  :
                  // 在首页的结果显示部分
                  isDesktop
                      ? GridView.count(
                          crossAxisCount: 3, // 3个一行
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.65, // 调整宽高比
                          children: _displayedResults
                              .map((property) => _buildResultCard(property,
                                  _displayedResults.indexOf(property) + 1))
                              .toList(),
                        )
                      : Column(
                          children: _displayedResults
                              .map((property) => Column(
                                    children: [
                                      _buildResultCard(
                                          property,
                                          _displayedResults.indexOf(property) +
                                              1),
                                      if (_displayedResults.indexOf(property) <
                                          _displayedResults.length - 1)
                                        const SizedBox(height: 20),
                                    ],
                                  ))
                              .toList(),
                        ),

              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  // _buildResultCard 方法和其他辅助方法保持不变...
  // 使用与之前相同的卡片设计，但添加排名功能
  Widget _buildResultCard(PropertyResult property, int rank) {
    final isRecommended = rank <= 3;
    final isWarning = property.ecoScore < 70;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: isRecommended
            ? Border.all(color: Colors.teal, width: 2)
            : (isWarning ? Border.all(color: Colors.red[200]!) : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 重要：防止高度溢出
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  property.imageUrl,
                  height: 140, // 减小图片高度
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // 排名徽章
              if (rank <= 3)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRankColor(rank).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getRankIcon(rank), size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _getRankText(rank),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Eco Score 徽章
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showScoreBreakdown(property.ecoScore),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(property.ecoScore).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          "${property.ecoScore}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.info_outline,
                            size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12), // 减小内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 重要：防止高度溢出
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // 减小字体大小
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      "RM${property.price}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 14, // 减小字体大小
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${property.area} • ${property.distanceToWork}km to work",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11, // 减小字体大小
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${property.details.bedrooms} Bed",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 9, // 减小字体大小
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${property.details.commuteTime}min",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 9, // 减小字体大小
                        ),
                      ),
                    ),
                    if (property.details.distanceToStation <= 500)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Walk to Station",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 9, // 减小字体大小
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Daily Commute Impact",
                  style: TextStyle(
                    fontSize: 9, // 减小字体大小
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: isWarning ? 8 : (isRecommended ? 2 : 5),
                        child: Container(
                          height: 4, // 减小高度
                          color: isWarning ? Colors.red : Colors.green,
                        ),
                      ),
                      Expanded(
                        flex: isWarning ? 2 : (isRecommended ? 8 : 5),
                        child: Container(
                          height: 4, // 减小高度
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isWarning ? "High Carbon" : "Low Carbon",
                      style: TextStyle(
                        fontSize: 9, // 减小字体大小
                        color: isWarning ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      isRecommended
                          ? "Save 40 mins"
                          : (isWarning ? "Lose 1 hr" : "Average"),
                      style: const TextStyle(
                        fontSize: 9, // 减小字体大小
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Show More Information Button
                    Expanded(
                      child: SizedBox(
                        height: 36, // 固定高度
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InformationHouseScreen(property: property),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "More Info",
                            style: TextStyle(fontSize: 11), // 减小字体大小
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Explain with AI Button
                    SizedBox(
                      height: 36, // 固定高度
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                initialContext: {
                                  'title': property.name,
                                  'price': 'RM${property.price}',
                                  'workplace': _workplace,
                                  'budget': 'RM ${_budget.round()}',
                                  'ecoScore': '${property.ecoScore}',
                                  'distance': '${property.distanceToWork}km',
                                  'commute':
                                      '${property.details.commuteTime}min',
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.smart_toy_outlined, size: 14),
                        label: const Text(
                          "AI Explain",
                          style: TextStyle(
                            fontSize: 11, // 减小字体大小
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.leaderboard;
    }
  }

  String _getRankText(int rank) {
    switch (rank) {
      case 1:
        return "1st";
      case 2:
        return "2nd";
      case 3:
        return "3rd";
      default:
        return "$rank" + "th";
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.teal;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  // Quick Filter Chip (保持不变)
  Widget _buildChoiceChip(String label, IconData icon) {
    final bool isSelected = _selectedChip == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedChip = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
