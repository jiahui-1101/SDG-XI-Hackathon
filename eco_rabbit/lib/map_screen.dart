import 'package:flutter/material.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedLayer = 0; // 0: Traffic, 1: Affordability, 2: Population
  double _vibeValue = 0.5;
  bool _showLegend = true;
  bool _showLabels = true;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _highlightedAreas = {};
  bool _showSearchResults = false;
  List<String> _searchSuggestions = [];

  final List<Map<String, dynamic>> _layerData = [
    {
      'name': 'Traffic Stress Map 🚗',
      'description': 'Real-time traffic congestion levels',
      'colors': [Colors.green, Colors.yellow, Colors.orange, Colors.red],
      'legend': ['Low', 'Moderate', 'High', 'Severe'],
    },
    {
      'name': 'Affordability Map 💰',
      'description': 'Housing cost distribution',
      'colors': [Colors.blue[100]!, Colors.blue[400]!, Colors.orange, Colors.red[700]!],
      'legend': ['Budget', 'Affordable', 'Moderate', 'Premium'],
    },
    {
      'name': 'Population Map 👥',
      'description': 'Population density and distribution',
      'colors': [Colors.green[100]!, Colors.green[400]!, Colors.orange, Colors.red[700]!],
      'legend': ['Sparse', 'Moderate', 'Dense', 'Very Dense'],
    },
  ];

  // Enhanced KL Area coordinates with more details
  final Map<String, Map<String, dynamic>> _klAreas = {
    'KLCC': {
      'position': Alignment(-0.2, -0.3),
      'traffic': 0.9,
      'affordability': 0.9,
      'population': 0.9,
      'label': 'KLCC',
      'type': 'CBD',
      'landmarks': ['Petronas Towers', 'KL Tower', 'Shopping Malls'],
      'keywords': ['klcc', 'petronas', 'twin towers', 'city center', 'cbd']
    },
    'Bangsar': {
      'position': Alignment(-0.5, -0.1),
      'traffic': 0.7,
      'affordability': 0.8,
      'population': 0.7,
      'label': 'Bangsar',
      'type': 'Upscale Residential',
      'landmarks': ['Bangsar Village', 'Restaurants'],
      'keywords': ['bangsar', 'village', 'upscale', 'residential']
    },
    'Subang': {
      'position': Alignment(-0.8, 0.1),
      'traffic': 0.7,
      'affordability': 0.6,
      'population': 0.5,
      'label': 'Subang',
      'type': 'Suburban',
      'landmarks': ['Subang Airport', 'Universities'],
      'keywords': ['subang', 'airport', 'ss15', 'universities']
    },
    'Ampang': {
      'position': Alignment(0.3, 0.0),
      'traffic': 0.3,
      'affordability': 0.4,
      'population': 0.7,
      'label': 'Ampang',
      'type': 'Residential',
      'landmarks': ['Embassies', 'Hills'],
      'keywords': ['ampang', 'embassies', 'hills', 'residential']
    },
    'Kepong': {
      'position': Alignment(-0.1, 0.4),
      'traffic': 0.8,
      'affordability': 0.3,
      'population': 0.8,
      'label': 'Kepong',
      'type': 'Residential',
      'landmarks': ['Forest Park', 'Temples'],
      'keywords': ['kepong', 'forest', 'park', 'temples']
    },
    'Cheras': {
      'position': Alignment(0.6, 0.5),
      'traffic': 0.6,
      'affordability': 0.5,
      'population': 0.8,
      'label': 'Cheras',
      'type': 'Residential',
      'landmarks': ['Leisure Mall', 'Markets'],
      'keywords': ['cheras', 'leisure mall', 'markets', 'residential']
    },
    'PJ': {
      'position': Alignment(-0.9, -0.1),
      'traffic': 0.7,
      'affordability': 0.7,
      'population': 0.6,
      'label': 'Petaling\nJaya',
      'type': 'Commercial',
      'landmarks': ['Universities', 'Tech Parks'],
      'keywords': ['petaling jaya', 'pj', 'universities', 'tech', 'commercial']
    },
    'Damansara': {
      'position': Alignment(-0.7, -0.2),
      'traffic': 0.6,
      'affordability': 0.8,
      'population': 0.6,
      'label': 'Damansara',
      'type': 'Upscale',
      'landmarks': ['Shopping Malls', 'Offices'],
      'keywords': ['damansara', 'malls', 'offices', 'upscale', 'damansara height']
    },
    'Setapak': {
      'position': Alignment(0.4, 0.2),
      'traffic': 0.5,
      'affordability': 0.4,
      'population': 0.7,
      'label': 'Setapak',
      'type': 'Residential',
      'landmarks': ['Universities', 'Hospitals'],
      'keywords': ['setapak', 'universities', 'hospitals', 'residential']
    },
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _showSearchResults = query.isNotEmpty;
      
      if (query.isEmpty) {
        _highlightedAreas.clear();
        _searchSuggestions.clear();
      } else {
        // Update highlighted areas based on search
        _highlightedAreas = _klAreas.entries
            .where((area) {
              final keywords = (area.value['keywords'] as List<dynamic>).cast<String>();
              return keywords.any((keyword) => keyword.contains(query));
            })
            .map((area) => area.key)
            .toSet();

        // Update search suggestions
        _searchSuggestions = _klAreas.entries
            .where((area) {
              final label = area.value['label'] as String;
              return label.toLowerCase().contains(query) && 
                     !_highlightedAreas.contains(area.key);
            })
            .map((area) => area.key)
            .toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _showSearchResults = false;
      _highlightedAreas.clear();
      _searchSuggestions.clear();
    });
  }

  void _selectSuggestion(String areaKey) {
    setState(() {
      _highlightedAreas = {areaKey};
      _searchController.text = _klAreas[areaKey]!['label'] as String;
      _searchSuggestions.clear();
    });
  }

  // 搜索范围功能
  void _searchWithRange(String query) {
    final queryLower = query.toLowerCase().trim();
    setState(() {
      _showSearchResults = queryLower.isNotEmpty;
      
      if (queryLower.isEmpty) {
        _highlightedAreas.clear();
      } else {
        // 查找匹配的区域
        final matchedAreas = _klAreas.entries
            .where((area) {
              final keywords = (area.value['keywords'] as List<dynamic>).cast<String>();
              final label = area.value['label'] as String;
              return keywords.any((keyword) => keyword.contains(queryLower)) ||
                     label.toLowerCase().contains(queryLower);
            })
            .map((area) => area.key)
            .toSet();

        // 如果有匹配的区域，显示10km范围内的所有区域
        if (matchedAreas.isNotEmpty) {
          final centerArea = matchedAreas.first;
          _highlightedAreas = _getAreasInRange(centerArea, 10.0); // 10km范围
        } else {
          _highlightedAreas.clear();
        }
      }
    });
  }

  // 获取指定范围内的区域
  Set<String> _getAreasInRange(String centerArea, double rangeKm) {
    final centerData = _klAreas[centerArea];
    if (centerData == null) return {centerArea};
    
    final Set<String> areasInRange = {};
    
    _klAreas.forEach((areaKey, areaData) {
      // 计算模拟距离（基于Alignment坐标的简单距离计算）
      final distance = _calculateDistance(
        centerData['position'] as Alignment,
        areaData['position'] as Alignment
      );
      
      // 将模拟距离转换为km（这里需要根据你的地图比例调整）
      final distanceKm = distance * 100; // 调整这个系数来匹配实际距离
      
      if (distanceKm <= rangeKm) {
        areasInRange.add(areaKey);
      }
    });
    
    return areasInRange;
  }

  // 计算两个Alignment坐标之间的距离
  double _calculateDistance(Alignment pos1, Alignment pos2) {
    final dx = pos1.x - pos2.x;
    final dy = pos1.y - pos2.y;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search KL areas (e.g., KLCC, Bangsar, Subang...)',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onChanged: (value) => _searchWithRange(value),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: _clearSearch,
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Search Results and Suggestions
                if (_showSearchResults) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Results
                        if (_highlightedAreas.isNotEmpty) ...[
                          const Text(
                            'Found Areas (10km radius):',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _highlightedAreas.map((areaKey) {
                              final area = _klAreas[areaKey]!;
                              return Chip(
                                label: Text(area['label']),
                                backgroundColor: Colors.blue[50],
                                onDeleted: () {
                                  setState(() {
                                    _highlightedAreas.remove(areaKey);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // No Results
                        if (_highlightedAreas.isEmpty) ...[
                          const Text(
                            'No areas found. Try "KLCC", "Bangsar", "Subang", etc.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 改进的标题部分 - 去掉白格，添加渐变背景和兔子照片
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 255, 255, 255),
                  const Color.fromARGB(255, 248, 248, 248),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 兔子照片
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 251, 250, 250).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/rabbit_look.png', // 请确保这个路径正确
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 如果图片加载失败，显示一个可爱的兔子图标
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 252, 252, 252),
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Colors.pink,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _layerData[_selectedLayer]['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.white,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _layerData[_selectedLayer]['description'],
                        style: TextStyle(
                          color: const Color.fromARGB(255, 39, 39, 39),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map Area
          Expanded(
            child: Stack(
              children: [
                // Static Map Background - Using a simple colored background with grid
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[50]!, Colors.green[50]!],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                  ),
                ),

                // Heatmap Areas - 只显示符合过滤条件的区域
                ..._klAreas.entries.map((area) {
                  final String areaKey = area.key;
                  final Map<String, dynamic> areaData = area.value;
                  final double intensity = _getAreaIntensity(areaKey, _selectedLayer);
                  final bool isHighlighted = _highlightedAreas.contains(areaKey);
                  
                  // 如果强度为-1，表示不应该显示这个区域
                  if (intensity < 0) {
                    return Container();
                  }
                  
                  return Align(
                    alignment: areaData['position'] as Alignment,
                    child: _buildHeatmapArea(
                      areaData['label'] as String,
                      intensity,
                      _selectedLayer,
                      areaData['type'] as String,
                      isHighlighted: isHighlighted,
                    ),
                  );
                }).toList(),

                // Area Labels - 只显示符合过滤条件的区域
                if (_showLabels) ..._klAreas.entries.map((area) {
                  final Map<String, dynamic> areaData = area.value;
                  final bool isHighlighted = _highlightedAreas.contains(area.key);
                  final double intensity = _getAreaIntensity(area.key, _selectedLayer);
                  
                  // 如果强度为-1，表示不应该显示这个区域
                  if (intensity < 0) {
                    return Container();
                  }
                  
                  return Align(
                    alignment: _getLabelPosition(areaData['position'] as Alignment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHighlighted ? Colors.blue : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isHighlighted ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ] : null,
                      ),
                      child: Text(
                        areaData['label'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isHighlighted ? 12 : 10,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Distance Indicator for Search Results
                if (_highlightedAreas.isNotEmpty)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Search Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Found ${_highlightedAreas.length} area${_highlightedAreas.length > 1 ? 's' : ''} within 10km',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Legend
                if (_showLegend)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildLegend(),
                  ),

                // Scale Bar
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: _buildScaleBar(),
                ),
              ],
            ),
          ),

          // Controls Panel
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // Layer Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLayerButton(0, Icons.traffic, 'Traffic'),
                    _buildLayerButton(1, Icons.attach_money, 'Affordability'),
                    _buildLayerButton(2, Icons.people, 'Population'),
                  ],
                ),

                const SizedBox(height: 20),

                // Additional Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      Icons.label,
                      'Labels',
                      _showLabels,
                      () => setState(() => _showLabels = !_showLabels),
                    ),
                    _buildControlButton(
                      Icons.legend_toggle,
                      'Legend',
                      _showLegend,
                      () => setState(() => _showLegend = !_showLegend),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Vibe Slider for all layers
                _buildVibeSlider(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建滑块UI
  Widget _buildVibeSlider() {
    String leftLabel;
    String rightLabel;
    IconData leftIcon;
    IconData rightIcon;
    String title;

    switch (_selectedLayer) {
      case 0: // Traffic
        leftLabel = 'Low Traffic';
        rightLabel = 'High Traffic';
        leftIcon = Icons.traffic;
        rightIcon = Icons.traffic;
        title = 'Traffic Level Filter';
        break;
      case 1: // Affordability
        leftLabel = 'Affordable';
        rightLabel = 'Expensive';
        leftIcon = Icons.attach_money;
        rightIcon = Icons.attach_money;
        title = 'Affordability Filter';
        break;
      case 2: // Population
        leftLabel = 'Low Density';
        rightLabel = 'High Density';
        leftIcon = Icons.people_outline;
        rightIcon = Icons.people_alt;
        title = 'Population Density Filter';
        break;
      default:
        leftLabel = 'Low';
        rightLabel = 'High';
        leftIcon = Icons.filter_list;
        rightIcon = Icons.filter_list;
        title = 'Density Filter';
    }

    return Column(
      children: [
        Row(
          children: [
            Icon(leftIcon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(leftIcon, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Slider(
                value: _vibeValue,
                onChanged: (value) => setState(() => _vibeValue = value),
                activeColor: Colors.blue,
                divisions: 4,
              ),
            ),
            const SizedBox(width: 10),
            Icon(rightIcon, color: Colors.orange),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            Text(rightLabel, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getVibeDescription(_vibeValue, _selectedLayer),
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getVibeDescription(double value, int layer) {
    if (layer == 2) { // Population
      if (value < 0.25) return 'Showing: Very Low Density Areas Only';
      if (value < 0.5) return 'Showing: Low Density Areas Only';
      if (value < 0.75) return 'Showing: Medium Density Areas Only';
      return 'Showing: All Density Areas';
    } else {
      if (value < 0.25) return 'Showing: Very Low Only';
      if (value < 0.5) return 'Showing: Low Only';
      if (value < 0.75) return 'Showing: Medium Only';
      return 'Showing: All Areas';
    }
  }

  Widget _buildHeatmapArea(String label, double intensity, int layer, String type, {bool isHighlighted = false}) {
    final Color color = _getHeatmapColor(intensity, layer);
    final double size = 50 + (intensity * 30);
    final IconData icon = _getAreaIcon(type);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.7),
        border: Border.all(
          color: isHighlighted ? Colors.white : Colors.white.withOpacity(0.8),
          width: isHighlighted ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isHighlighted ? 0.6 : 0.4),
            blurRadius: isHighlighted ? 20 : 15,
            spreadRadius: isHighlighted ? 5 : 3,
          ),
          if (isHighlighted)
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 8,
            ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isHighlighted ? 20 : 16, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label.contains('\n') ? label.split('\n')[0] : label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.bold,
                fontSize: isHighlighted ? 10 : 8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerButton(int index, IconData icon, String label) {
    final isSelected = _selectedLayer == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _selectedLayer = index),
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.teal : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive ? Colors.blue[50] : Colors.transparent,
            foregroundColor: isActive ? Colors.blue : Colors.grey[700],
            side: BorderSide(color: isActive ? Colors.blue : Colors.grey[300]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final currentLayer = _layerData[_selectedLayer];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentLayer['name']} Legend',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...List.generate(currentLayer['colors'].length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: currentLayer['colors'][index],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentLayer['legend'][index],
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScaleBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 4,
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          const Text(
            '2 km',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(double intensity, int layer) {
    final colors = _layerData[layer]['colors'];
    if (intensity < 0.25) return colors[0];
    if (intensity < 0.5) return colors[1];
    if (intensity < 0.75) return colors[2];
    return colors[3];
  }

  // 修改获取区域强度的方法，加入过滤逻辑
  double _getAreaIntensity(String areaKey, int layer) {
    final area = _klAreas[areaKey]!;
    final double rawValue;
    
    switch (layer) {
      case 0: // Traffic
        rawValue = area['traffic'] as double;
        // 根据交通滑块值过滤
        return _shouldShowArea(rawValue, _vibeValue, false) ? rawValue : -1;
      case 1: // Affordability
        rawValue = area['affordability'] as double;
        // 根据 affordability 滑块值过滤
        return _shouldShowArea(rawValue, _vibeValue, false) ? rawValue : -1;
      case 2: // Population
        rawValue = area['population'] as double;
        // 根据人口密度滑块值过滤
        return _shouldShowArea(rawValue, _vibeValue, true) ? rawValue : -1;
      default:
        return 0.5;
    }
  }

  // 判断是否应该显示该区域
  bool _shouldShowArea(double areaValue, double sliderValue, bool isPopulation) {
    if (isPopulation) {
      // 人口密度逻辑：滑块向左(少人)时显示低密度区域
      if (sliderValue < 0.25) {
        return areaValue <= 0.4; // 低密度
      } else if (sliderValue < 0.5) {
        return areaValue <= 0.6; // 中低密度
      } else if (sliderValue < 0.75) {
        return areaValue <= 0.8; // 中高密度
      } else {
        return true; // 显示所有
      }
    } else {
      // 交通和 affordability 逻辑：滑块向左时显示低值区域
      if (sliderValue < 0.25) {
        return areaValue <= 0.4;
      } else if (sliderValue < 0.5) {
        return areaValue <= 0.6;
      } else if (sliderValue < 0.75) {
        return areaValue <= 0.8;
      } else {
        return true;
      }
    }
  }

  IconData _getAreaIcon(String type) {
    switch (type) {
      case 'CBD':
        return Icons.business;
      case 'Upscale Residential':
        return Icons.villa;
      case 'Commercial':
        return Icons.shopping_cart;
      case 'Upscale':
        return Icons.star;
      default:
        return Icons.home;
    }
  }

  Alignment _getLabelPosition(Alignment areaPosition) {
    return Alignment(
      areaPosition.x + 0.1,
      areaPosition.y + 0.15,
    );
  }
}

// Custom painter for map grid background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw main roads
    final roadPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 2;

    // Main horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      roadPaint,
    );

    // Main vertical road
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}