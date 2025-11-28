import 'package:flutter/material.dart';
import 'result_display_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 1500;
  double _monthlySalary = 5000; // 新增月薪滑块
  double _vibeValue = 0.5;
  String _selectedChip = "Near MRT";
  bool _hasSearched = false; // 控制是否显示结果部分
  String _workplace = ""; // 存储工作地点

  void _performSearch() {
    if (_workplace.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter workplace location')),
      );
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    // 导航到结果页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDisplayScreen(
          workplace: _workplace,
          budget: _budget,
          monthlySalary: _monthlySalary,
        ),
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
              "Hi, Alex Tan ",
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"),
            radius: 18,
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
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
                          // Budget slider
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.45
                                : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Monthly Budget",
                                      style: TextStyle(fontWeight: FontWeight.bold),
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
                          // Monthly Salary slider (新增)
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.45
                                : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Monthly Salary",
                                      style: TextStyle(fontWeight: FontWeight.bold),
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
                                  onChanged: (v) => setState(() => _monthlySalary = v),
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
                      const Icon(Icons.local_fire_department, color: Colors.red),
                    ],
                  ),
                  Center(
                    child: Text(
                      _vibeValue < 0.5 ? "Currently: Quiet Area" : "Currently: Vibrant Area",
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
                        backgroundColor: Colors.teal,
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

              // ---------- Top 3 AI Picks ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Top 3 AI Picks For You",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultDisplayScreen(
                            workplace: _workplace,
                            budget: _budget,
                            monthlySalary: _monthlySalary,
                            showAllResults: true, // 直接显示所有结果
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 显示前3个推荐
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildTop3Cards(),
                    )
                  : Column(
                      children: _buildTop3Cards(),
                    ),

              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTop3Cards() {
    // 这里可以调用你的Eco Score算法来获取前3个结果
    final topProperties = _getTop3Properties();
    
    if (MediaQuery.of(context).size.width > 800) {
      // 桌面布局
      return topProperties.map((property) => Expanded(child: property)).toList();
    } else {
      // 移动布局
      List<Widget> cards = [];
      for (int i = 0; i < topProperties.length; i++) {
        cards.add(topProperties[i]);
        if (i < topProperties.length - 1) {
          cards.add(const SizedBox(height: 20));
        }
      }
      return cards;
    }
  }

  List<Widget> _getTop3Properties() {
    // 模拟前3个房源数据 - 在实际应用中这里会调用你的Eco Score算法
    return [
      _buildPropertyCard(
        imageUrl: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        title: "Cheras Green Condo",
        price: "RM 1,300",
        location: "Cheras • 400m to MRT",
        matchRate: 98,
        tags: const ["High Connectivity", "Value"],
        isRecommended: true,
        ecoScore: 92,
      ),
      _buildPropertyCard(
        imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        title: "Bangsar South Loft",
        price: "RM 1,800",
        location: "Bangsar South • 200m to LRT",
        matchRate: 92,
        tags: const ["Luxury", "Vibrant"],
        isRecommended: false,
        ecoScore: 88,
      ),
      _buildPropertyCard(
        imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        title: "Setapak Budget Flat",
        price: "RM 1,100",
        location: "Setapak • Car Dependent",
        matchRate: 45,
        tags: const ["Traffic Jam Risk"],
        isRecommended: false,
        isWarning: true,
        ecoScore: 62,
      ),
    ];
  }

  // --- Quick Filter Chip ---
  Widget _buildChoiceChip(String label, IconData icon) {
    final bool isSelected = _selectedChip == label;
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

  // --- Property Card with Explain with AI ---
  // --- Property Card with Explain with AI ---
  Widget _buildPropertyCard({
    required String imageUrl,
    required String title,
    required String price,
    required String location,
    required int matchRate,
    required List<String> tags,
    required bool isRecommended,
    required int ecoScore,
    bool isWarning = false,
  }) {
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
        children: [
          // 图片
          // 图片
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isWarning
                        ? Colors.red
                        : (matchRate > 90
                            ? Colors.teal
                            : Colors.orange),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$matchRate% Match",
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
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(ecoScore).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "$ecoScore",
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
            ],
          ),

          // 文本内容

          // 文本内容
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),


                Wrap(
                  spacing: 8,
                  children: tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),


                const SizedBox(height: 15),
                const Text(
                  "Daily Commute Impact",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  "Daily Commute Impact",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: isWarning ? 8 : (isRecommended ? 2 : 5),
                        child: Container(
                          height: 6,
                          color: isWarning ? Colors.red : Colors.green,
                        ),
                      ),
                      Expanded(
                        flex: isWarning ? 2 : (isRecommended ? 8 : 5),
                        child: Container(
                          height: 6,
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isWarning ? "High Carbon" : "Low Carbon",
                      style: TextStyle(
                        fontSize: 10,
                        color: isWarning ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      isRecommended ? "Save 40 mins" : (isWarning ? "Lose 1 hr" : "Average"),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Show More Information Button
                    // 查找 Show More Information Button 并修改：
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
      // 这里可以导航到详情页面
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // 绿底
                        foregroundColor: Colors.white, // 白字
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
    child: const Text(
      "Show More Information",
      style: TextStyle(fontSize: 12),
    ),
  ),
),
                    const SizedBox(width: 8),
                    // Explain with AI Button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              initialContext: {
                                'title': title,
                                'price': price,
                                'workplace': _workplace,
                                'budget': 'RM ${_budget.round()}',
                                'ecoScore': '$ecoScore',
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.smart_toy_outlined, size: 16),
                      label: const Text(
                        "AI Explain",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.teal;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}