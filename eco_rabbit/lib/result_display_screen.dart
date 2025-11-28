// result_display_screen.dart
import 'package:flutter/material.dart';
import 'information_house_screen.dart';
import 'models/property_model.dart';
import 'chat_screen.dart';

class ResultDisplayScreen extends StatefulWidget {
  final String workplace;
  final double budget;
  final double monthlySalary;
  final bool showAllResults;

  const ResultDisplayScreen({
    super.key,
    required this.workplace,
    required this.budget,
    required this.monthlySalary,
    this.showAllResults = false,
  });

  @override
  State<ResultDisplayScreen> createState() => _ResultDisplayScreenState();
}

class _ResultDisplayScreenState extends State<ResultDisplayScreen> {
  List<PropertyResult> _allResults = [];
  List<PropertyResult> _displayedResults = [];
  bool _showAllResults = false;

  @override
  void initState() {
    super.initState();
    _showAllResults = widget.showAllResults;
    _loadAndCalculateResults();
  }

  // Eco Score 算法实现
  double _calculateEcoScore(PropertyResult property) {
    // 1. 可负担性分数 (30%) - 租金占月薪的比例
    double affordabilityScore = _calculateAffordabilityScore(property.price);
    
    // 2. 交通便利度分数 (40%) - 基于到车站距离和通勤时间
    double connectivityScore = _calculateConnectivityScore(
      property.details.distanceToStation,
      property.details.commuteTime
    );
    
    // 3. 低交通风险分数 (30%) - 基于到工作地点距离和区域拥堵情况
    double trafficRiskScore = _calculateTrafficRiskScore(
      property.distanceToWork,
      property.area
    );
    
    // 综合分数 = 30%可负担性 + 40%交通便利度 + 30%低交通风险
    double finalScore = (affordabilityScore * 0.3) + 
                       (connectivityScore * 0.4) + 
                       (trafficRiskScore * 0.3);
    
    return finalScore.clamp(0, 100); // 确保分数在0-100之间
  }

  double _calculateAffordabilityScore(double rent) {
    // 租金占月薪比例越小，分数越高
    double rentToSalaryRatio = rent / widget.monthlySalary;
    
    if (rentToSalaryRatio <= 0.2) return 100;      // 租金占20%以下：满分
    if (rentToSalaryRatio <= 0.3) return 80;       // 租金占30%以下：80分
    if (rentToSalaryRatio <= 0.4) return 60;       // 租金占40%以下：60分
    if (rentToSalaryRatio <= 0.5) return 40;       // 租金占50%以下：40分
    return 20;                                     // 租金超过50%：20分
  }

  double _calculateConnectivityScore(int distanceToStation, int commuteTime) {
    double stationScore = 0;
    double commuteScore = 0;
    
    // 车站距离分数
    if (distanceToStation <= 200) stationScore = 100;
    else if (distanceToStation <= 500) stationScore = 80;
    else if (distanceToStation <= 1000) stationScore = 60;
    else if (distanceToStation <= 1500) stationScore = 40;
    else stationScore = 20;
    
    // 通勤时间分数
    if (commuteTime <= 20) commuteScore = 100;
    else if (commuteTime <= 35) commuteScore = 80;
    else if (commuteTime <= 50) commuteScore = 60;
    else if (commuteTime <= 65) commuteScore = 40;
    else commuteScore = 20;
    
    // 综合交通分数 = 60%车站距离 + 40%通勤时间
    return (stationScore * 0.6) + (commuteScore * 0.4);
  }

  double _calculateTrafficRiskScore(double distanceToWork, String area) {
    double distanceScore = 0;
    double areaScore = 0;
    
    // 距离分数 - 距离越近分数越高
    if (distanceToWork <= 5) distanceScore = 100;
    else if (distanceToWork <= 10) distanceScore = 80;
    else if (distanceToWork <= 15) distanceScore = 60;
    else if (distanceToWork <= 20) distanceScore = 40;
    else distanceScore = 20;
    
    // 区域拥堵风险分数 - 根据区域类型判断
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
      areaScore = 60; // 默认分数
    }
    
    // 综合交通风险分数 = 50%距离 + 50%区域拥堵风险
    return (distanceScore * 0.5) + (areaScore * 0.5);
  }

  void _loadAndCalculateResults() {
    // 模拟数据
    final mockResults = [
      PropertyResult(
        id: '1',
        name: 'Green Residence Mont Kiara',
        distanceToWork: 8.5,
        area: 'Mont Kiara',
        price: 1200,
        imageUrl: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 2,
          bathrooms: 2,
          size: 850,
          amenities: ['Pool', 'Gym', 'MRT Shuttle'],
          commuteTime: 35,
          distanceToStation: 350,
        ),
        ecoScore: 0, // 临时值，后面计算
      ),
      PropertyResult(
        id: '2',
        name: 'Eco Suites Bangsar South',
        distanceToWork: 6.2,
        area: 'Bangsar South',
        price: 1400,
        imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
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
        name: 'KLCC Sky View Condo',
        distanceToWork: 3.5,
        area: 'KLCC',
        price: 1800,
        imageUrl: "https://images.unsplash.com/photo-1513584684374-8bab748fbf90?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
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
        id: '4',
        name: 'PJ Eco Living Apartment',
        distanceToWork: 12.3,
        area: 'Petaling Jaya',
        price: 1100,
        imageUrl: "https://images.unsplash.com/photo-1567496898669-ee935f5f647a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 2,
          bathrooms: 1,
          size: 750,
          amenities: ['Park', 'Shopping Mall'],
          commuteTime: 45,
          distanceToStation: 800,
        ),
        ecoScore: 0,
      ),
      PropertyResult(
        id: '5',
        name: 'Cheras Green Home',
        distanceToWork: 15.2,
        area: 'Cheras',
        price: 950,
        imageUrl: "https://images.unsplash.com/photo-1574362848149-11496d93a7c7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
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
        id: '6',
        name: 'Damansara Heights Villa',
        distanceToWork: 7.8,
        area: 'Damansara',
        price: 1600,
        imageUrl: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        details: PropertyDetails(
          bedrooms: 3,
          bathrooms: 2,
          size: 1200,
          amenities: ['Pool', 'Garden', 'Security'],
          commuteTime: 30,
          distanceToStation: 600,
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
      _displayedResults = _showAllResults ? _allResults : _allResults.take(3).toList();
    });
  }

  void _showScoreBreakdown(PropertyResult property) {
    final affordability = _calculateAffordabilityScore(property.price);
    final connectivity = _calculateConnectivityScore(
      property.details.distanceToStation, 
      property.details.commuteTime
    );
    final trafficRisk = _calculateTrafficRiskScore(property.distanceToWork, property.area);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eco Score Calculation Breakdown"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreMetric("Affordability (30%)", 
                "Rent/Salary Ratio: RM${property.price}/RM${widget.monthlySalary.round()}", 
                affordability, 0.3),
            _buildScoreMetric("Transport Connectivity (40%)", 
                "Station: ${property.details.distanceToStation}m, Commute: ${property.details.commuteTime}min", 
                connectivity, 0.4),
            _buildScoreMetric("Low Traffic Risk (30%)", 
                "Distance: ${property.distanceToWork}km, Area: ${property.area}", 
                trafficRisk, 0.3),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Final Eco Score:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${property.ecoScore}/100", 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                ],
              ),
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

  Widget _buildScoreMetric(String title, String description, double score, double weight) {
    final weightedScore = score * weight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${weightedScore.toStringAsFixed(1)} pts", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[200],
            color: Colors.teal,
          ),
          Text("Base Score: ${score.toStringAsFixed(1)}/100", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eco-Friendly Homes Results"),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Workplace: ${widget.workplace}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Budget: RM${widget.budget.toInt()} • Salary: RM${widget.monthlySalary.toInt()}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showAllResults ? "All Results (${_allResults.length})" : "Top 3 Recommendations",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (!_showAllResults && _allResults.length > 3)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllResults = true;
                        _displayedResults = _allResults;
                      });
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(color: Colors.teal),
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

            // Results Grid - 使用与首页相同的UI
            isDesktop
                ? Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: _displayedResults.map((property) => 
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 3,
                        child: _buildPropertyCard(property, _displayedResults.indexOf(property) + 1),
                      )
                    ).toList(),
                  )
                : Column(
                    children: _displayedResults.map((property) => 
                      Column(
                        children: [
                          _buildPropertyCard(property, _displayedResults.indexOf(property) + 1),
                          if (_displayedResults.indexOf(property) < _displayedResults.length - 1)
                            const SizedBox(height: 20),
                        ],
                      )
                    ).toList(),
                  ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(PropertyResult property, int rank) {
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
        children: [
          // 图片
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  property.imageUrl,
                  height: 160,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRankColor(rank).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
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
                  onTap: () => _showScoreBreakdown(property),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(property.ecoScore).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
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
                        const Icon(Icons.info_outline, size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 文本内容
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "RM${property.price}",
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
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      "${property.area} • ${property.distanceToWork}km to work",
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${property.details.bedrooms} Bedrooms",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${property.details.commuteTime}min Commute",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (property.details.distanceToStation <= 500)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Walk to Station",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InformationHouseScreen(property: property),
                            ),
                            );
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
                                'title': property.name,
                                'price': 'RM${property.price}',
                                'workplace': widget.workplace,
                                'budget': 'RM${widget.budget.round()}',
                                'ecoScore': '${property.ecoScore}',
                                'distance': '${property.distanceToWork}km',
                                'commute': '${property.details.commuteTime}min',
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return Icons.emoji_events;
      case 2: return Icons.workspace_premium;
      case 3: return Icons.military_tech;
      default: return Icons.leaderboard;
    }
  }

  String _getRankText(int rank) {
  switch (rank) {
    case 1: return "1st";
    case 2: return "2nd";
    case 3: return "3rd";
    default: return "$rank" + "th";
  }
}

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.teal;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}