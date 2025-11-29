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
  double _timeYearValue = 2025; // Future Time Travel

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

  // KL Coordinates
  final Map<String, Map<String, dynamic>> _klAreas = {
    'KLCC': {
      'position': const Alignment(-0.2, -0.3),
      'traffic': 0.9, 'affordability': 0.9, 'population': 0.9,
      'label': 'KLCC', 'type': 'CBD', 'keywords': ['klcc', 'petronas', 'cbd']
    },
    'Bangsar': {
      'position': const Alignment(-0.5, -0.1),
      'traffic': 0.7, 'affordability': 0.8, 'population': 0.7,
      'label': 'Bangsar', 'type': 'Upscale Residential', 'keywords': ['bangsar']
    },
    'Subang': {
      'position': const Alignment(-0.8, 0.1),
      'traffic': 0.7, 'affordability': 0.6, 'population': 0.5,
      'label': 'Subang', 'type': 'Suburban', 'keywords': ['subang']
    },
    'Ampang': {
      'position': const Alignment(0.3, 0.0),
      'traffic': 0.3, 'affordability': 0.4, 'population': 0.7,
      'label': 'Ampang', 'type': 'Residential', 'keywords': ['ampang']
    },
    'Kepong': {
      'position': const Alignment(-0.1, 0.4),
      'traffic': 0.8, 'affordability': 0.3, 'population': 0.8,
      'label': 'Kepong', 'type': 'Residential', 'keywords': ['kepong']
    },
    'Cheras': {
      'position': const Alignment(0.6, 0.5),
      'traffic': 0.6, 'affordability': 0.5, 'population': 0.8,
      'label': 'Cheras', 'type': 'Residential', 'keywords': ['cheras']
    },
    'PJ': {
      'position': const Alignment(-0.9, -0.1),
      'traffic': 0.7, 'affordability': 0.7, 'population': 0.6,
      'label': 'Petaling\nJaya', 'type': 'Commercial', 'keywords': ['pj']
    },
    'Damansara': {
      'position': const Alignment(-0.7, -0.2),
      'traffic': 0.6, 'affordability': 0.8, 'population': 0.6,
      'label': 'Damansara', 'type': 'Upscale', 'keywords': ['damansara']
    },
    'Setapak': {
      'position': const Alignment(0.4, 0.2),
      'traffic': 0.5, 'affordability': 0.4, 'population': 0.7,
      'label': 'Setapak', 'type': 'Residential', 'keywords': ['setapak']
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

  // --- SEARCH LOGIC ---
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _showSearchResults = query.isNotEmpty;
      if (query.isEmpty) {
        _highlightedAreas.clear();
      } else {
        _highlightedAreas = _klAreas.entries
            .where((area) {
              final keywords = (area.value['keywords'] as List<dynamic>).cast<String>();
              final label = area.value['label'] as String;
              return keywords.any((keyword) => keyword.contains(query)) || label.toLowerCase().contains(query);
            })
            .map((area) => area.key)
            .toSet();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _showSearchResults = false;
      _highlightedAreas.clear();
    });
  }

  void _searchWithRange(String query) {
    _onSearchChanged();
    if (_highlightedAreas.isNotEmpty) {
      final centerArea = _highlightedAreas.first;
      _highlightedAreas = _getAreasInRange(centerArea, 10.0);
    }
  }

  Set<String> _getAreasInRange(String centerArea, double rangeKm) {
    final centerData = _klAreas[centerArea];
    if (centerData == null) return {centerArea};
    final Set<String> areasInRange = {};
    _klAreas.forEach((areaKey, areaData) {
      final distance = _calculateDistance(centerData['position'] as Alignment, areaData['position'] as Alignment);
      if (distance * 100 <= rangeKm) areasInRange.add(areaKey);
    });
    return areasInRange;
  }

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
          // 标题部分 - 兔子照片回归
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8), Color(0xFFFFFFFF)],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: ClipOval(
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
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _layerData[_selectedLayer]['name'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, shadows: [Shadow(blurRadius: 2, color: Colors.white, offset: Offset(1, 1))]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _layerData[_selectedLayer]['description'],
                        style: const TextStyle(color: Color.fromARGB(255, 39, 39, 39), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
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
                            hintText: 'Search KL areas (e.g., KLCC, Bangsar...)',
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
                
                // 搜索结果 (Blue Chips)
                if (_showSearchResults) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_highlightedAreas.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.blue),
                              const SizedBox(width: 5),
                              Text('Found ${_highlightedAreas.length} Areas (10km Radius):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8, runSpacing: 4,
                            children: _highlightedAreas.map((areaKey) {
                              return Chip(
                                label: Text(_klAreas[areaKey]!['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.white,
                                elevation: 2,
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => setState(() => _highlightedAreas.remove(areaKey)),
                              );
                            }).toList(),
                          ),
                        ] else 
                          const Text('No areas found.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Map Area
          Expanded(
            child: Stack(
              children: [
                // 🔥 1. MAP BACKGROUND (Ultimate Stability)
                // Layer A: Base Color (Beige - Land Color)
                Container(color: const Color(0xFFF2EFE9)), 

                // Layer B: Grid (Always visible fallback)
                CustomPaint(
                  painter: _MapGridPainter(), 
                  size: Size.infinite,
                ),

                // Layer C: Local Image Asset (PLEASE ADD assets/kl_map.png)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.5, // 让地图稍微淡一点，突出 Heatmap
                    child: Image.asset(
                      'assets/kl_map.png', 
                      fit: BoxFit.cover,
                      // 如果你懒得找图，这个 errorBuilder 会自动帮你切换回 网格模式，不会崩
                      errorBuilder: (context, error, stackTrace) {
                        return Container(); // 找不到图就显示透明，露出底下的 Grid
                      },
                    ),
                  ),
                ),

                // 2. Heatmap Layers
                ..._klAreas.entries.map((area) {
                  final String areaKey = area.key;
                  final Map<String, dynamic> areaData = area.value;
                  final double intensity = _getAreaIntensity(areaKey, _selectedLayer);
                  final bool isHighlighted = _highlightedAreas.contains(areaKey);
                  if (intensity < 0) return Container();
                  return Align(
                    alignment: areaData['position'] as Alignment,
                    child: _buildHeatmapArea(
                      areaData['label'] as String,
                      intensity,
                      _selectedLayer,
                      areaData['type'] as String,
                      isHighlighted: isHighlighted,
                      currentYear: _timeYearValue,
                    ),
                  );
                }).toList(),

                // 3. Labels
                if (_showLabels) ..._klAreas.entries.map((area) {
                  final Map<String, dynamic> areaData = area.value;
                  final double intensity = _getAreaIntensity(area.key, _selectedLayer);
                  if (intensity < 0) return Container();
                  final bool isHighlighted = _highlightedAreas.contains(area.key);
                  return Align(
                    alignment: _getLabelPosition(areaData['position'] as Alignment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHighlighted ? Colors.blue : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isHighlighted ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)] : null,
                      ),
                      child: Text(
                        areaData['label'] as String,
                        style: TextStyle(color: Colors.white, fontSize: isHighlighted ? 12 : 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),

                if (_showLegend) Positioned(top: 20, left: 20, child: _buildLegend()),
                Positioned(bottom: 20, left: 20, child: _buildScaleBar()),
                Positioned(
                  top: 20, right: 20,
                  child: Column(
                    children: [
                      _buildMapControlButton(Icons.add, () {}),
                      const SizedBox(height: 8),
                      _buildMapControlButton(Icons.remove, () {}),
                      const SizedBox(height: 16),
                      _buildMapControlButton(Icons.my_location, () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Controls Panel
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLayerButton(0, Icons.traffic, 'Traffic'),
                    _buildLayerButton(1, Icons.attach_money, 'Affordability'),
                    _buildLayerButton(2, Icons.people, 'Population'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(Icons.label, 'Labels', _showLabels, () => setState(() => _showLabels = !_showLabels)),
                    _buildControlButton(Icons.legend_toggle, 'Legend', _showLegend, () => setState(() => _showLegend = !_showLegend)),
                  ],
                ),
                const SizedBox(height: 20),

                // SPLIT: Left (Original Filter) | Right (Time Travel)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildVibeSlider()), // Restored Original Colors
                    const SizedBox(width: 15),
                    Expanded(flex: 6, child: _buildTimeTravelSlider()),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 RESTORED: 原版 Filter Bar 样式 (Blue/Teal Style)
  Widget _buildVibeSlider() {
    String leftLabel;
    String rightLabel;
    IconData leftIcon;
    IconData rightIcon;
    String title;
    
    // 原本的颜色逻辑
    Color activeColor = Colors.teal; // 默认
    if (_selectedLayer == 0) activeColor = Colors.redAccent;
    if (_selectedLayer == 1) activeColor = Colors.blue;

    switch (_selectedLayer) {
      case 0: leftLabel = 'Low'; rightLabel = 'High'; leftIcon = Icons.traffic; rightIcon = Icons.traffic; title = 'Traffic Filter'; break;
      case 1: leftLabel = 'Cheap'; rightLabel = 'Pricey'; leftIcon = Icons.attach_money; rightIcon = Icons.attach_money; title = 'Price Filter'; break;
      case 2: leftLabel = 'Sparse'; rightLabel = 'Dense'; leftIcon = Icons.people_outline; rightIcon = Icons.people_alt; title = 'Density Filter'; break;
      default: leftLabel = 'Low'; rightLabel = 'High'; leftIcon = Icons.filter_list; rightIcon = Icons.filter_list; title = 'Filter';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(leftIcon, size: 14, color: Colors.grey),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(leftIcon, size: 16, color: activeColor), // Icon 跟随颜色
            const SizedBox(width: 5),
            Expanded(
              child: SizedBox(
                height: 20,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: activeColor, // 👈 动态颜色回归
                    thumbColor: activeColor,
                    inactiveTrackColor: activeColor.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    trackHeight: 4.0,
                  ),
                  child: Slider(
                    value: _vibeValue,
                    onChanged: (value) => setState(() => _vibeValue = value),
                    divisions: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Icon(rightIcon, size: 16, color: activeColor), // Icon 跟随颜色
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel, style: TextStyle(color: Colors.grey[700], fontSize: 9)),
            Text(rightLabel, style: TextStyle(color: Colors.grey[700], fontSize: 9)),
          ],
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            _getVibeDescription(_vibeValue, _selectedLayer),
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 9),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTravelSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.rocket_launch, size: 14, color: Colors.indigo),
            const SizedBox(width: 5),
            Text("Future Time-Travel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.indigo[800])),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text("2025", style: TextStyle(fontSize: 9, color: Colors.indigo[300])),
            Expanded(
              child: SizedBox(
                height: 20,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.indigo,
                    inactiveTrackColor: Colors.indigo[100],
                    thumbColor: Colors.indigoAccent,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    trackHeight: 3.0,
                  ),
                  child: Slider(
                    value: _timeYearValue,
                    min: 2025,
                    max: 2030,
                    divisions: 5,
                    onChanged: (value) => setState(() => _timeYearValue = value),
                  ),
                ),
              ),
            ),
            Text("2030", style: TextStyle(fontSize: 9, color: Colors.indigo[800], fontWeight: FontWeight.bold)),
          ],
        ),
        Center(
          child: Text(
            "Year: ${_timeYearValue.toInt()}",
            style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.bold, fontSize: 9),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapArea(String label, double intensity, int layer, String type, {bool isHighlighted = false, required double currentYear}) {
    final Color color = _getHeatmapColor(intensity, layer);
    
    double futureFactor = (currentYear - 2025) / 5.0;
    double baseSize = 50 + (intensity * 30);
    baseSize += (futureFactor * 25 * intensity);

    final double size = baseSize;
    final IconData icon = _getAreaIcon(type);

    double opacity = 0.7;
    opacity += futureFactor * 0.2; 
    if (opacity > 0.9) opacity = 0.9;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: color.withOpacity(opacity),
        border: Border.all(color: Colors.white, width: isHighlighted ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isHighlighted ? 0.6 : 0.4),
            blurRadius: isHighlighted ? 20 : 15,
            spreadRadius: isHighlighted ? 5 : (3 + futureFactor * 4),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isHighlighted ? 20 : 16, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label.split('\n')[0],
              style: TextStyle(color: Colors.white, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.bold, fontSize: isHighlighted ? 10 : 8),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerButton(int index, IconData icon, String label) {
    final isSelected = _selectedLayer == index;
    // Button Colors
    Color btnColor = Colors.teal;
    if (index == 0) btnColor = Colors.redAccent;
    if (index == 1) btnColor = Colors.blue;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _selectedLayer = index),
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? btnColor : Colors.grey[200], // Dynamic
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${currentLayer['name']} Legend', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        ...List.generate(currentLayer['colors'].length, (index) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Container(width: 16, height: 16, decoration: BoxDecoration(color: currentLayer['colors'][index], borderRadius: BorderRadius.circular(2))), const SizedBox(width: 8), Text(currentLayer['legend'][index], style: const TextStyle(fontSize: 10))]))),
      ]),
    );
  }

  Widget _buildScaleBar() {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Row(children: [Container(width: 40, height: 4, color: Colors.black), const SizedBox(width: 8), const Text('2 km', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]));
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]), child: IconButton(icon: Icon(icon, size: 20), onPressed: onPressed, color: Colors.grey[700]));
  }

  Color _getHeatmapColor(double intensity, int layer) {
    final colors = _layerData[layer]['colors'];
    if (intensity < 0.25) return colors[0]; if (intensity < 0.5) return colors[1]; if (intensity < 0.75) return colors[2]; return colors[3];
  }

  double _getAreaIntensity(String areaKey, int layer) {
    final area = _klAreas[areaKey]!;
    final double rawValue;
    switch (layer) {
      case 0: rawValue = area['traffic'] as double; return _shouldShowArea(rawValue, _vibeValue, false) ? rawValue : -1;
      case 1: rawValue = area['affordability'] as double; return _shouldShowArea(rawValue, _vibeValue, false) ? rawValue : -1;
      case 2: rawValue = area['population'] as double; return _shouldShowArea(rawValue, _vibeValue, true) ? rawValue : -1;
      default: return 0.5;
    }
  }

  bool _shouldShowArea(double areaValue, double sliderValue, bool isPopulation) {
    if (isPopulation) {
      if (sliderValue < 0.25) return areaValue <= 0.4;
      else if (sliderValue < 0.5) return areaValue <= 0.6;
      else if (sliderValue < 0.75) return areaValue <= 0.8;
      else return true;
    } else {
      if (sliderValue < 0.25) return areaValue <= 0.4;
      else if (sliderValue < 0.5) return areaValue <= 0.6;
      else if (sliderValue < 0.75) return areaValue <= 0.8;
      else return true;
    }
  }

  IconData _getAreaIcon(String type) {
    switch (type) {
      case 'CBD': return Icons.business; case 'Upscale Residential': return Icons.villa; case 'Commercial': return Icons.shopping_cart; case 'Upscale': return Icons.star; default: return Icons.home;
    }
  }

  Alignment _getLabelPosition(Alignment areaPosition) {
    return Alignment(areaPosition.x + 0.1, areaPosition.y + 0.15);
  }

  String _getVibeDescription(double value, int layer) {
    if (layer == 2) { if (value < 0.25) return 'Showing: Very Low Density'; if (value < 0.5) return 'Showing: Low Density'; if (value < 0.75) return 'Showing: Medium Density'; return 'Showing: All Density'; } else { if (value < 0.25) return 'Showing: Very Low Only'; if (value < 0.5) return 'Showing: Low Only'; if (value < 0.75) return 'Showing: Medium Only'; return 'Showing: All Areas'; }
  }
}

// 原始 Grid Painter
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 20) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 20) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    final roadPaint = Paint()..color = Colors.grey.withOpacity(0.5)..strokeWidth = 2;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), roadPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}